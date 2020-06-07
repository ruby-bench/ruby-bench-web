class Repo < ApplicationRecord
  has_many :commits, dependent: :destroy
  has_many :releases, dependent: :destroy
  has_many :benchmark_types, dependent: :destroy
  belongs_to :organization

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :url, presence: true, uniqueness: true
  validates :organization_id, presence: true

  def title
    name.capitalize
  end

  def generate_sparkline_data
    return if self.commits.empty?

    charts = {}

    query = <<~SQL
      WITH min_max_dates AS (
        SELECT MIN(date_trunc('week', created_at)) AS start_week,
               MAX(date_trunc('week', created_at)) AS end_week
        FROM (
          SELECT created_at
          FROM commits
          WHERE repo_id = #{self.id}
        ) AS subq
      ),
      weeks AS (
        SELECT generate_series(start_week, end_week, '7 days') AS weekstart
        FROM min_max_dates
      )
      SELECT
        subquery.*
      FROM (
        SELECT
          benchmark_result_type_id,
          benchmark_type_id,
          array_to_json(array_agg(br.id)) AS ids
        FROM (
          SELECT id FROM (
            SELECT
              ROW_NUMBER() OVER(PARTITION BY w.weekstart ORDER BY c.created_at) AS row_num,
              id
            FROM weeks w
            INNER JOIN commits c
            ON w.weekstart = date_trunc('week', c.created_at) AND c.repo_id = #{self.id}
          ) x
          WHERE row_num = 1
        ) cw
        INNER JOIN benchmark_runs br
        ON cw.id = br.initiator_id AND br.initiator_type = 'Commit'
        INNER JOIN benchmark_types bt
        ON bt.id = br.benchmark_type_id AND bt.repo_id = #{self.id}
        GROUP BY benchmark_type_id, benchmark_result_type_id
      ) AS subquery
      INNER JOIN benchmark_types
      ON benchmark_types.id = subquery.benchmark_type_id
      INNER JOIN benchmark_result_types
      ON benchmark_result_types.id = subquery.benchmark_result_type_id
      ORDER BY category, name
    SQL

    results = self.class.connection.execute(query).to_a
    results.each do |row|
      row['ids'] = JSON.parse(row['ids'])
    end

    types = self.benchmark_types
                .where(id: results.map { |row| row['benchmark_type_id'] }.uniq)
                .map { |type| [type.id, type] }.to_h
    result_types = BenchmarkResultType
                   .where(id: results.map { |row| row['benchmark_result_type_id'] }.uniq)
                   .map { |res_type| [res_type.id, res_type] }.to_h
    all_runs = BenchmarkRun
               .select(:id, :initiator_id, :result, :initiator_type, 'c.created_at')
               .joins("JOIN commits c ON c.id = benchmark_runs.initiator_id AND benchmark_runs.initiator_type = 'Commit'")
               .where(id: results.map { |row| row['ids'] }.flatten.uniq)
               .map { |run| [run.id, run] }.to_h

    results.each do |res|
      type = types[res['benchmark_type_id']]
      result_type = result_types[res['benchmark_result_type_id']]
      runs = all_runs.values_at(*res['ids']).sort_by(&:created_at)
      next if !type || !result_type || runs.size == 0

      chart_builder = ChartBuilder.new(runs, result_type).build_columns
      charts[type.category] ||= []
      charts[type.category] << {
        benchmark_result_type: result_type.name,
        columns: chart_builder.columns
      }
    end

    $redis.setex("sparklines:#{self.id}", 1800, charts.to_msgpack)
    charts
  end
end

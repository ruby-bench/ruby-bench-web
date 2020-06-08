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
        benchmark_result_type_id,
        benchmark_type_id,
        hstore_to_json(br.result) AS result,
        category
      FROM (
        SELECT id, commit_date FROM (
          SELECT
            ROW_NUMBER() OVER(PARTITION BY w.weekstart ORDER BY c.created_at) AS row_num,
            id,
            created_at AS commit_date
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
      ORDER BY category, commit_date
    SQL

    raw_results = self.class.connection.execute(query).to_a
    raw_results.each do |row|
      row['result'] = JSON.parse(row['result'])
    end

    result_types = BenchmarkResultType
                   .where(id: raw_results.map { |row| row['benchmark_result_type_id'] }.uniq)
                   .map { |res_type| [res_type.id, res_type] }.to_h

    results = {}
    raw_results.each do |res|
      results[res['benchmark_type_id']] ||= {}
      results[res['benchmark_type_id']]['category'] = res['category']
      hash = results[res['benchmark_type_id']]['res_types'] ||= {}
      arr = hash[result_types[res['benchmark_result_type_id']].name] ||= []
      arr << res['result']
      hash.sort_by { |k| k }
      results[res['benchmark_type_id']]['res_types'] = hash.sort_by { |k, v| k }.to_h
    end
    results.values.each do |res|
      category = res['category']
      next unless category
      res['res_types'].each do |name, runs|
        chart_builder = ChartBuilder.new(runs, nil).build_columns_hash
        charts[category] ||= []
        charts[category] << {
          benchmark_result_type: name,
          columns: chart_builder.columns
        }
      end
    end

    $redis.setex("sparklines:#{self.id}", 1800, charts.to_msgpack)
    charts
  end
end

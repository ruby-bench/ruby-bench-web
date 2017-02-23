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

    self.benchmark_types.map do |benchmark_type|
      benchmark_type.benchmark_result_types.each do |benchmark_result_type|
        benchmark_runs = BenchmarkRun.select(:initiator_id, :result, :initiator_type).fetch_commit_benchmark_runs(
          benchmark_type.category,
          benchmark_result_type,
          2000
        )

        runs = benchmark_runs.sort_by { |run| run.initiator.created_at }
        chart_builder = ChartBuilder.new(runs, benchmark_result_type)

        charts[benchmark_type.category] ||= []
        charts[benchmark_type.category] << [benchmark_result_type.name, chart_builder.build_columns]
      end
    end

    $redis.setex("sparklines:#{self.id}", 1800, charts.to_json)
    charts
  end
end

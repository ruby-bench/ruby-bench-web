class Repo < ApplicationRecord
  has_many :commits, dependent: :destroy
  has_many :releases, dependent: :destroy
  has_many :benchmarks, dependent: :destroy
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

    self.benchmarks.map do |benchmark|
      benchmark.result_types.each do |result_type|
        benchmark_runs = BenchmarkRun.select(:initiator_id, :result, :initiator_type).fetch_commit_benchmark_runs(
          benchmark.label,
          result_type,
          2000
        )

        runs = benchmark_runs.sort_by { |run| run.initiator.created_at }
        chart_builder = ChartBuilder.new(runs, result_type).build_columns

        charts[benchmark.label] ||= []
        charts[benchmark.label] << {
          result_type: result_type.name,
          columns: chart_builder.columns
        }
      end
    end

    $redis.setex("sparklines:#{self.id}", 1800, charts.to_msgpack)
    charts
  end
end

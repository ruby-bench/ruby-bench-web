class BenchmarkRun < ApplicationRecord
  belongs_to :initiator, polymorphic: true
  belongs_to :benchmark
  belongs_to :result_type

  validates :result, presence: true
  validates :environment, presence: true
  validates :initiator_id, presence: true
  validates :initiator_type, presence: true
  validates :benchmark_id, presence: true
  validates :result_type_id, presence: true
  validates :validity, presence: true

  # FIXME: Remove this and order by Commit#created_at
  default_scope { order("#{self.table_name}.created_at DESC") }

  scope :fetch_commit_benchmark_runs, -> (benchmark_label, result_type, limit) {
    unscope(:order)
    .joins(:benchmark)
    .joins('INNER JOIN commits ON commits.id = benchmark_runs.initiator_id')
    .includes(:initiator)
    .where(
      benchmarks: { label: benchmark_label },
      benchmark: result_type,
      initiator_type: 'Commit',
      validity: true
    )
    .order('commits.created_at DESC')
    .limit(limit)
  }

  scope :fetch_release_benchmark_runs, -> (benchmark_label, result_type) {
    joins(:benchmark)
    .includes(:initiator)
    .where(
      benchmarks: { label: benchmark_label },
      result_type: result_type,
      initiator_type: 'Release',
      validity: true
    )
  }

  PAGINATE_COUNT = [20, 50 , 100, 200, 400, 500, 750, 1000, 2000]
  DEFAULT_PAGINATE_COUNT = 2000

  def self.sort_by_initiator_version(benchmark_runs)
    benchmark_runs.sort_by do |benchmark_run|
      begin
        Gem::Version.new(benchmark_run.initiator.version)
      rescue
        # Set to a high number such that strings will always be last
        Gem::Version.new(999)
      end
    end
  end

  def self.latest_commit_benchmark_run(benchmark, result_type)
    self.unscope(:order)
    .joins('INNER JOIN commits ON commits.id = benchmark_runs.initiator_id')
    .where(
      initiator_type: 'Commit',
      result_type: result_type,
      benchmark: benchmark
    )
    .order('commits.created_at DESC')
    .first
  end

  def self.charts_cache_key(benchmark, result_type)
    "charts:#{benchmark.id}:#{result_type.id}"
  end
end

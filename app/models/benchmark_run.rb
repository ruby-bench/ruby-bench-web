class BenchmarkRun < ActiveRecord::Base
  belongs_to :initiator, polymorphic: true
  belongs_to :benchmark_type
  belongs_to :benchmark_result_type

  validates :result, presence: true
  validates :environment, presence: true
  validates :initiator_id, presence: true
  validates :initiator_type, presence: true
  validates :benchmark_type_id, presence: true
  validates :benchmark_result_type_id, presence: true
  validates :validity, presence: true

  # FIXME: Remove this and order by Commit#created_at
  default_scope { order("#{self.table_name}.created_at DESC")}

  scope :fetch_commit_benchmark_runs, ->(form_result_type, benchmark_result_type, limit) {
    unscope(:order)
    .joins(:benchmark_type)
    .joins("INNER JOIN commits ON commits.id = benchmark_runs.initiator_id")
    .includes(:initiator)
    .where(
      benchmark_types: { category: form_result_type },
      benchmark_result_type: benchmark_result_type,
      initiator_type: 'Commit',
      validity: true
    )
    .order("commits.created_at DESC")
    .limit(limit)
  }

  scope :fetch_release_benchmark_runs, ->(form_result_type, benchmark_result_type) {
    joins(:benchmark_type)
    .includes(:initiator)
    .where(
      benchmark_types: { category: form_result_type },
      benchmark_result_type: benchmark_result_type,
      initiator_type: 'Release',
      validity: true
    )
  }

  PAGINATE_COUNT = [20, 50 ,100, 200, 400, 500, 750, 1000, 2000]
  DEFAULT_PAGINATE_COUNT = 200

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

  def self.latest_commit_benchmark_run(benchmark_type, benchmark_result_type)
    self.unscope(:order)
      .joins("INNER JOIN commits ON commits.id = benchmark_runs.initiator_id")
      .where(
        initiator_type: 'Commit',
        benchmark_result_type: benchmark_result_type,
        benchmark_type: benchmark_type
      )
      .order("commits.created_at DESC")
      .first
  end
end

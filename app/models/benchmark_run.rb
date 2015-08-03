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

  default_scope { order("#{self.table_name}.created_at DESC")}

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
end

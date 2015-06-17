class BenchmarkType < ActiveRecord::Base
  default_scope { order("#{self.table_name}.category ASC") }

  has_many :benchmark_runs, dependent: :destroy
  belongs_to :repo

  validates :category, presence: true, uniqueness: { scope: [:repo_id, :script_url] }
  validates :unit, presence: true
  validates :script_url, presence: true

  def latest_benchmark_run(initiator_type)
    self.benchmark_runs.where(initiator_type: initiator_type).first
  end
end

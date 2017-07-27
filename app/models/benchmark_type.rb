class BenchmarkType < ApplicationRecord
  default_scope { order("#{self.table_name}.category ASC") }
  scope :all_except, -> (user) { where.not(id: user) }

  has_many :benchmark_runs, dependent: :destroy

  has_many :benchmark_result_types, -> {
    unscope(:order).order('benchmark_result_types.id').distinct
  }, through: :benchmark_runs

  belongs_to :repo
  has_and_belongs_to_many :groups

  after_update :check_benchmark_runs_validity

  validates :category, presence: true, uniqueness: { scope: [:repo_id, :script_url] }
  validates :script_url, presence: true

  def github_url
    uri = URI.parse(self.script_url)
    uri.path =~ /\A(\/[^\/]*\/[^\/]*\/)(.*)\z/
    "https://github.com#{$1}blob/#{$2}"
  end

  def comparison_benchmark_types
    BenchmarkType.joins(:groups).where('benchmark_types_groups.group_id' => groups.ids).where.not(id: id)
  end

  private

  def check_benchmark_runs_validity
    if self.digest_was && self.digest_changed?
      self.benchmark_runs.update_all(validity: false)
    end
  end
end

class BenchmarkType < ActiveRecord::Base
  default_scope { order("#{self.table_name}.category ASC") }

  has_many :benchmark_runs, dependent: :destroy
  belongs_to :repo

  validates :category, presence: true, uniqueness: { scope: [:repo_id, :script_url] }
  validates :script_url, presence: true

  def github_url
    uri = URI.parse(self.script_url)
    uri.path =~ /\A(\/[^\/]*\/[^\/]*\/)(.*)\z/
    "https://github.com#{$1}blob/#{$2}"
  end
end

class Commit < ActiveRecord::Base
  belongs_to :repo
  has_many :benchmark_runs

  validates :sha1, presence: true, length: { minimum: 5 }
  # TODO: Add validation of URL
  validates :url, presence: true
  validates :repo_id, presence: true
  validates :message, presence: true
end

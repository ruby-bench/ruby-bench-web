class Commit < ActiveRecord::Base
  MERGE_COMMIT_MESSAGE = 'Merge pull request'.freeze
  CI_SKIP_COMMIT_MESSAGE = 'ci skip'.freeze
  SKIP_CI_COMMIT_MESSAGE = 'skip ci'.freeze

  default_scope -> { order('commits.created_at DESC') }

  belongs_to :repo
  has_many :benchmark_runs, as: :initiator, dependent: :destroy

  validates :sha1, presence: true, length: { minimum: 5 }, uniqueness: { scope: :repo_id }
  # TODO: Add validation of URL
  validates :url, presence: true
  validates :repo_id, presence: true
  validates :message, presence: true

  class << self
    def merge_or_skip_ci?(message)
      !message.match(
        /#{CI_SKIP_COMMIT_MESSAGE}|#{MERGE_COMMIT_MESSAGE}|#{SKIP_CI_COMMIT_MESSAGE}/
      ).nil?
    end
  end
end

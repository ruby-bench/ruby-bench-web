class Commit < ActiveRecord::Base
  extend CommitReviewer

  default_scope { order("#{self.table_name}.created_at DESC") }

  belongs_to :repo
  has_many :benchmark_runs, as: :initiator, dependent: :destroy

  validates :sha1, presence: true, length: { minimum: 5 }, uniqueness: { scope: :repo_id }

  validates :url, presence: true
  validates_format_of :url, with: URI::regexp(%w(http https))
  validates :repo_id, presence: true
  validates :message, presence: true

  def version
    "latest commit: #{self.sha1[0..5]}"
  end
end

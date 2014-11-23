class Commit < ActiveRecord::Base
  belongs_to :repo

  validates :sha1, presence: true, length: { minimum: 5 }
  # TODO: Add validation of URL
  validates :url, presence: true
  validates :repo_id, presence: true
end

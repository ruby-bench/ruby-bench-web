class Release < ApplicationRecord
  belongs_to :repo
  has_many :benchmark_runs, as: :initiator, dependent: :destroy

  validates :version, presence: true
  validates :repo_id, presence: true
end

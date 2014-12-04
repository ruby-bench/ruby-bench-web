class Repo < ActiveRecord::Base
  has_many :commits
  belongs_to :organization

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :url, presence: true, uniqueness: true
  validates :organization_id, presence: true
end

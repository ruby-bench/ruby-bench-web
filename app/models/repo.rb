class Repo < ActiveRecord::Base
  has_many :commits, dependent: :destroy
  has_many :releases, dependent: :destroy
  has_many :benchmark_types, dependent: :destroy
  belongs_to :organization

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :url, presence: true, uniqueness: true
  validates :organization_id, presence: true
end

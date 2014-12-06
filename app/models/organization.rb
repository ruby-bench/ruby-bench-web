class Organization < ActiveRecord::Base
  has_many :repos, dependent: :destroy

  validates :name, presence: true
  validates :url, presence: true
end

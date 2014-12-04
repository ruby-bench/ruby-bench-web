class Organization < ActiveRecord::Base
  has_many :repos

  validates :name, presence: true
  validates :url, presence: true
end

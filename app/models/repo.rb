class Repo < ActiveRecord::Base
  has_many :commits

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
end

class Organization < ApplicationRecord
  has_many :repos, dependent: :destroy

  validates :name, presence: true
  validates :url, presence: true

  def title
    name.capitalize
  end
end

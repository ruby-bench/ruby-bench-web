class BenchmarkRun < ActiveRecord::Base
  belongs_to :commit

  validates :category, presence: true
  validates :result, presence: true
  validates :environment, presence: true
  validates :commit_id, presence: true
end

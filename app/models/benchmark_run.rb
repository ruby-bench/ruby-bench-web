class BenchmarkRun < ActiveRecord::Base
  belongs_to :initiator, polymorphic: true

  validates :category, presence: true
  validates :result, presence: true
  validates :environment, presence: true
  validates :initiator_id, presence: true
  validates :initiator_type, presence: true
  validates :unit, presence: true
end

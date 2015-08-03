class BenchmarkResultType < ActiveRecord::Base
  validates :name, presence: true, uniqueness: { scope: :unit }
  validates :unit, presence: true, uniqueness: { scope: :name }
end

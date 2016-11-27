class BenchmarkResultType < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :unit }
  validates :unit, presence: true, uniqueness: { scope: :name }
end

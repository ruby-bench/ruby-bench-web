class Group < ApplicationRecord
  has_and_belongs_to_many :benchmark_types
end

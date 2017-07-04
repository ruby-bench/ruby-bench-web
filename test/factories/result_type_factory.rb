FactoryGirl.define do
  factory :result_type do
    sequence(:name) { |n| "Execution time#{n}" }
    sequence(:unit) { |n| "Seconds#{n}" }
  end
end

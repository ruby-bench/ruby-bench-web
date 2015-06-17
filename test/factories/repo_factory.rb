FactoryGirl.define do
  factory :repo do
    association :organization
    sequence(:name) { |n| "repo#{n}" }
    sequence(:url) { |n| "http://repo#{n}.com" }
  end
end

FactoryGirl.define do
  factory :organization do
    sequence(:name) { |n| "organization#{n}" }
    sequence(:url) { |n| "http://organization#{n}.com" }
  end
end

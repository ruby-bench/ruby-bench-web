FactoryGirl.define do
  factory :benchmark_type do
    association :repo
    sequence(:category) { |n| "category#{n}" }
    unit "seconds"
    script_url "http://somescript.com"
  end
end

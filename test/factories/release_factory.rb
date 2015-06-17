FactoryGirl.define do
  factory :release do
    association :repo
    sequence(:version) { |n| "#{n}.#{n}.#{n}-p#{n}#{n}#{n}" }
  end
end

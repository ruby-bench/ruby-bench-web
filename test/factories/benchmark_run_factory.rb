FactoryGirl.define do
  factory :benchmark_run do
    association :benchmark_type
    result { { 'sometime' => 5 } }
    environment "some environment"

    factory :release_benchmark_run do
      association :initiator, factory: :release
    end

    factory :commit_benchmark_run do
      association :initiator, factory: :commit
    end
  end
end

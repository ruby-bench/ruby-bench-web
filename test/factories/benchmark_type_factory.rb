FactoryGirl.define do
  factory :benchmark_type do
    association :repo
    sequence(:category) { |n| "category#{n}" }
    unit "seconds"
    script_url "https://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_app_answer.rb"
  end
end

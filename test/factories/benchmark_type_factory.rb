FactoryGirl.define do
  factory :benchmark_type do
    association :repo
    sequence(:category) { |n| "bm_category#{n}" }
    script_url 'https://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_app_answer.rb'
    digest 'abcde'
  end
end

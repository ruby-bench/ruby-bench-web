FactoryGirl.define do
  factory :benchmark do
    association :repo
    sequence(:label) { |n| "bm_label#{n}" }
    script_url 'https://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_app_answer.rb'
    digest 'abcde'
  end
end

FactoryGirl.define do
  factory :commit do
    association :repo
    sequence(:sha1) { |n| "#{n}" * 7 }
    url 'https://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_app_answer.rb'
    message 'Did something'
  end
end

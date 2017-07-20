FactoryGirl.define do
  factory :group do
    sequence(:name) { |i| "group#{i}" }
    description 'Random group'
  end
end

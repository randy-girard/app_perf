FactoryGirl.define do
  factory :application do
    name Faker::Internet.domain_word
    data_retention_hours 1
    user
  end
end

FactoryGirl.define do
  factory :application do
    name Faker::Internet.domain_word
    data_retention_hours 24
    user
  end
end

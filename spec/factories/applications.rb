FactoryGirl.define do
  factory :application do
    name Faker::Internet.domain_word
    user
  end
end

FactoryGirl.define do
  factory :application do
    name Faker::Internet.domain_word
    data_retention_hours 1

    transient do
      user nil
    end
  end
end

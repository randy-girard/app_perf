FactoryGirl.define do
  factory :application do
    name Faker::Internet.domain_word

    transient do
      user nil
    end
  end
end

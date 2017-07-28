FactoryGirl.define do
  factory :organization do
    user nil
    name "MyString"

    after(:create) do |organization, evaluator|
      organization.users << evaluator.user if evaluator.user
    end
  end
end

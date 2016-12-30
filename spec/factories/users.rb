FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "user#{n}@example.com" }
    password               "password"
    password_confirmation  "password"
    license_key { SecureRandom.uuid }
  end
end

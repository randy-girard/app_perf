FactoryBot.define do
  factory :event do
    type { "" }
    application { nil }
    start_time { "2017-01-06 09:25:59" }
    end_time { "2017-01-06 09:25:59" }
    title { "MyString" }
    description { "MyString" }
  end
end

FactoryBot.define do
  factory :log_entry do
    span { nil }
    event { "MyString" }
    timestamp { "2017-10-27 22:08:23" }
    fields { "MyText" }
  end
end

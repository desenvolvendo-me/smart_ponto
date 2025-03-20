FactoryBot.define do
  factory :time_entry do
    user { nil }
    date { "2025-03-19" }
    time { "2025-03-19 21:43:51" }
    entry_type { "MyString" }
    status { "MyString" }
    observation { "MyText" }
    signature { false }
  end
end

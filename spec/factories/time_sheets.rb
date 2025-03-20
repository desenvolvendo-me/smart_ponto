FactoryBot.define do
  factory :time_sheet do
    user { nil }
    date { "2025-03-19" }
    status { "MyString" }
    total_hours { "9.99" }
    approval_status { "MyString" }
    approved_by { 1 }
    approved_at { "2025-03-19 21:42:21" }
  end
end

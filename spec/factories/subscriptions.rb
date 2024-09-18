FactoryBot.define do
  factory :subscription do
    receipt_number { "MyString" }
    expires_on { "2024-09-17" }
    credits_left { 1 }
    credit_log { "MyString" }
    next_payment_date { "2024-09-17" }
    active { false }
    subscribed_on { "2024-09-17" }
    number_of_payments { 1 }
    company { nil }
    package { nil }
  end
end

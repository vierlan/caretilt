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
    company { 2 }
    package { nil }

    trait :active do
      active { true }
      expires_on { 1.year.from_now }

    end

    trait :expired do
      active { false }
      expires_on { 1.day.ago }
    end
  end
end

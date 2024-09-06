FactoryBot.define do
  factory :company do
    name { "MyString" }
    type { "" }
    companies_house_id { 1 }
    registered_address { "MyString" }
    phone_number { "MyString" }
    billing_address { "MyString" }
  end
end

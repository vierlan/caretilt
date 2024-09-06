FactoryBot.define do
  factory :care_home do
    name { "MyString" }
    address { "" }
    phone_number { "MyString" }
    main_contact { "MyString" }
    short_description { "MyText" }
    long_description { "MyText" }
    type_of_home { "MyString" }
    types_of_client_group { "MyString" }
    company { nil }
    latitude { 1.5 }
    longitude { 1.5 }
  end
end

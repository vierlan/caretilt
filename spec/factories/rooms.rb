FactoryBot.define do
  factory :room do
    name { "MyString" }
    core_fee_level { 1 }
    core_hours_of_care { 1 }
    additional_fees_associated { false }
    other_data { "" }
    single { "MyString" } # Assuming 'single' is an attribute
    double { "MyString" } # Assuming 'double' is an attribute
    ensuite { false }
    care_home { nil }
  end
end

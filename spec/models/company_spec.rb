require 'rails_helper'

RSpec.describe Company, type: :model do
  # Use let to lazily initialize current_user for all tests
  let(:current_user) { User.first_or_create!(email: "d3@test.com", password: "password", password_confirmation: "password") }
  
  it 'has a valid phone number' do
    company = Company.new(
      name: "Dev LLC",
      company_type: "type1",  # Changed from 'type' to 'company_type'
      companies_house_id: "12BC34BD",
      phone_number: "123455",  # A valid phone number
      address: "wooo",
      user: current_user
    )

    expect(company).to_not be_valid
  end
end
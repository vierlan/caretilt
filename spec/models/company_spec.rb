# bundle exec rspec spec/models/company_spec.rb   

require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:current_user) { User.first_or_create!(email: "d3@test.com", password: "password", password_confirmation: "password") }

  # Define a subject to represent a valid Company instance
  subject do
    Company.new(
      name: "Dev LLC",
      companies_house_id: "12BC34BD",
      phone_number: "07822031222",  # A valid phone number
      address1: "123 Test St",
      address2: "Suite 100",
      city: "Test City",
      postcode: "LE89HN",
    )
  end

  describe 'validations' do
    it 'is valid with all required fields' do
      expect(subject).to be_valid
    end

    it 'is invalid with missing or incorrect fields' do
      aggregate_failures 'testing invalid fields' do
        subject.name = nil
        expect(subject).to_not be_valid
        expect(subject.errors[:name]).to include("can't be blank")

        subject.companies_house_id = "123"  # Invalid length
        expect(subject).to_not be_valid
        expect(subject.errors[:companies_house_id]).to include("must be 8 alphanumeric characters")

        subject.postcode = nil
        expect(subject).to_not be_valid
        expect(subject.errors[:postcode]).to include("can't be blank")
      end
    end
  end

  describe 'associations' do
    it 'belongs to a user and has many associations' do
      aggregate_failures 'testing associations' do
        assoc = described_class.reflect_on_association(:users)
        expect(assoc.macro).to eq :has_many

        assoc = described_class.reflect_on_association(:care_homes)
        expect(assoc.macro).to eq :has_many

        assoc = described_class.reflect_on_association(:subscriptions)
        expect(assoc.macro).to eq :has_many

        assoc = described_class.reflect_on_association(:packages)
        expect(assoc.macro).to eq :has_many
        expect(assoc.options[:through]).to eq(:subscriptions)
      end
    end
  end
end

# bundle exec rspec spec/models/room_spec.rb    

require 'rails_helper'

RSpec.describe Room, type: :model do
  let(:company) { Company.first_or_create(name: "Test Company", companies_house_id: "12BC34BD", postcode: "LE89HN") }
  let!(:local_authority_data) { LocalAuthorityData.first_or_create!(nice_name: "Greater London") }
  let(:care_home) {
    CareHome.first_or_create!(
      name: "Test Care Home",
      main_contact: "John Doe",
      short_description: "A short description",
      long_description: "A longer description",
      type_of_home: "Adult Homes",
      types_of_client_group: "Older People",
      address1: "Test",
      address2: "Test",
      city: "London",
      postcode: "SY175DT",
      local_authority_name: "Greater London",
      company: company
    )
  }

  subject do
    Room.new(
      name: "Test room",
      core_fee_level: 10,
      core_hours_of_care: 40,
      single_double: 'Single Room',
      ensuite: true,
      additional_fees_associated: false,
      care_home: care_home
    )
  end

  context 'validations' do
    it 'is valid with all the required fields' do
      expect(subject).to be_valid
    end

    it 'is invalid without a name' do
      subject.name = nil
      aggregate_failures do
        expect(subject).not_to be_valid
        expect(subject.errors[:name]).to include("Name cannot be blank")
      end
    end

    it 'validates core fee level correctly' do
      aggregate_failures "testing core_fee_level validations" do
        # Empty core_fee_level
        subject.core_fee_level = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:core_fee_level]).to include("can't be blank")
    
        # Negative core_fee_level
        subject.core_fee_level = -10
        expect(subject).not_to be_valid
        expect(subject.errors[:core_fee_level]).to include("Fee needs to be above 0.")
    
        # Decimal core_fee_level
        subject.core_fee_level = 10.5
        expect(subject).to be_valid  # Assuming decimals are allowed
    
        # Valid core_fee_level (positive integer)
        subject.core_fee_level = 100
        expect(subject).to be_valid
      end
    end

    it 'validates core hours of care correctly' do
      aggregate_failures "testing core_hours_of_care validations" do
        # Empty core_hours_of_care
        subject.core_hours_of_care = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:core_hours_of_care]).to include("Core hours of care cannot be blank")
        
        # Negative core_hours_of_care
        subject.core_hours_of_care = -10
        expect(subject).not_to be_valid
        expect(subject.errors[:core_hours_of_care]).to include("Core hours of care needs to be above 0")
        
        # Decimal core_hours_of_care
        subject.core_hours_of_care = 10.5
        expect(subject).not_to be_valid  # Assuming decimals are not allowed
        
        # Valid core_hours_of_care (positive integer)
        subject.core_hours_of_care = 100
        expect(subject).to be_valid
      end
    end
  end
end

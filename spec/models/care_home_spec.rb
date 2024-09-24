# bundle exec rspec spec/models/care_home_spec.rb    

require 'rails_helper'

RSpec.describe CareHome, type: :model do

  # We use lets for 'supporting dependencies' when creating our test.
  # Care homes need a company as a parent so we makeit here.
  let(:company) { Company.first_or_create(name: "Test Company") }
  let!(:local_authority_data) { LocalAuthorityData.create!(nice_name: "Greater London") }

  
  # Define the subject with the necessary attributes. This is the model we're continuously running tests on.
  subject do
    CareHome.new(
      name: "Test Care Home",
      main_contact: "John Doe",
      short_description: "A short description",
      long_description: "A longer description",
      type_of_home: "Adult Homes",
      types_of_client_group: "Older People",
      postcode: "SY175DT",
      local_authority_name: "Greater London",
      company: company
    )
  end

  context 'validations' do
    it 'is valid with all required fields' do
      expect(subject).to be_valid
    end

    it 'is invalid without a name' do
      subject.name = nil
      aggregate_failures do
        expect(subject).not_to be_valid
        expect(subject.errors[:name]).to include("Name cannot be blank")
      end
    end

    it 'is invalid without a main contact' do
      subject.main_contact = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:main_contact]).to include("Main contact cannot be blank")
    end

    it 'is invalid without a short description' do
      subject.short_description = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:short_description]).to include("Short description cannot be blank")
    end

    it 'is invalid with a short description longer than 300 characters' do
      subject.short_description = "A" * 301
      expect(subject).not_to be_valid
      expect(subject.errors[:short_description]).to include("Short description must be between 1 and 300 characters")
    end

    it 'is invalid with a long description longer than 800 characters' do
      subject.long_description = "A" * 801
      expect(subject).not_to be_valid
      expect(subject.errors[:long_description]).to include("Long description must be between 1 and 800 characters")
    end

    it 'is invalid without a type of home' do
      subject.type_of_home = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:type_of_home]).to include("Type of home cannot be blank")
    end

    it 'is invalid with an incorrect type of home' do
      subject.type_of_home = "Invalid Type"
      expect(subject).not_to be_valid
      expect(subject.errors[:type_of_home]).to include("Invalid Type is not a valid home type")
    end

    it 'is invalid without a types of client group' do
      subject.types_of_client_group = ['']
      expect(subject).not_to be_valid
      expect(subject.errors[:types_of_client_group]).to include("Types of client group cannot be blank")
    end

    it 'is invalid with an incorrect types of client group' do
      subject.types_of_client_group = "Invalid Group"
      expect(subject).not_to be_valid
      expect(subject.errors[:types_of_client_group]).to include("Invalid Group is not a valid client type")
    end

    it 'is invalid with an incorrect phone number' do
      subject.phone_number = "07387174"
      expect(subject).not_to be_valid
      expect(subject.errors[:phone_number]).to include("must be a valid UK phone number")
    end
  end

  context 'associations' do
    it 'belongs to a company' do
      assoc = described_class.reflect_on_association(:company)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'has many users' do
      assoc = described_class.reflect_on_association(:users)
      expect(assoc.macro).to eq :has_many
    end

    it 'has many rooms' do
      assoc = described_class.reflect_on_association(:rooms)
      expect(assoc.macro).to eq :has_many
    end
  end
end

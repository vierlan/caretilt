require 'rails_helper'

# bundle exec rspec spec/models/care_home_spec.rb     

RSpec.describe CareHome, type: :model do
  let(:company) { Company.first_or_create(name: "Test Company") }
  let(:current_user) { User.first_or_create!(email: "rtest@test.com", password: 'password', password_confirmation: 'password', company: company) }

  context 'validations' do
    it 'is valid with all required fields' do
      care_home = CareHome.new(
        name: "Test Care Home",
        main_contact: "John Doe",
        short_description: "A short description",
        long_description: "A longer description",
        type_of_home: "Adult Homes",
        types_of_client_group: "Older People",
        postcode: "SY175DT",
        company: company
      )

      # If the care_home is invalid, print the errors
    unless care_home.valid?
      puts "Validation errors: #{care_home.errors.full_messages}"
    end

      expect(care_home).to be_valid
    end

    it 'is invalid without a name' do
      care_home = CareHome.new(name: nil)
      expect(care_home).not_to be_valid
      expect(care_home.errors[:name]).to include("Name cannot be blank")
    end

    it 'is invalid without a main contact' do
      care_home = CareHome.new(main_contact: nil)
      expect(care_home).not_to be_valid
      expect(care_home.errors[:main_contact]).to include("Main contact cannot be blank")
    end

    it 'is invalid without a short description' do
      care_home = CareHome.new(short_description: nil)
      expect(care_home).not_to be_valid
      expect(care_home.errors[:short_description]).to include("Short description cannot be blank")
    end

    it 'is invalid with a short description longer than 50 characters' do
      care_home = CareHome.new(short_description: "A" * 51)
      expect(care_home).not_to be_valid
      expect(care_home.errors[:short_description]).to include("Short description must be between 1 and 50 characters")
    end

    it 'is invalid with a long description longer than 200 characters' do
      care_home = CareHome.new(long_description: "A" * 201)
      expect(care_home).not_to be_valid
      expect(care_home.errors[:long_description]).to include("Long description must be between 1 and 200 characters")
    end

    it 'is invalid without a type of home' do
      care_home = CareHome.new(type_of_home: nil)
      expect(care_home).not_to be_valid
      expect(care_home.errors[:type_of_home]).to include("Type of home cannot be blank")
    end

    it 'is invalid with an incorrect type of home' do
      care_home = CareHome.new(type_of_home: "Invalid Type")
      expect(care_home).not_to be_valid
      expect(care_home.errors[:type_of_home]).to include("Invalid Type is not a valid home type")
    end

    it 'is invalid without a types of client group' do
      care_home = CareHome.new(types_of_client_group: nil)
      expect(care_home).not_to be_valid
      expect(care_home.errors[:types_of_client_group]).to include("Types of client group cannot be blank")
    end

    it 'is invalid with an incorrect types of client group' do
      care_home = CareHome.new(types_of_client_group: "Invalid Group")
      expect(care_home).not_to be_valid
      expect(care_home.errors[:types_of_client_group]).to include("Invalid Group is not a valid client type")
    end

    it 'is invalid with an incorrect phone number' do
      care_home = CareHome.new(phone_number: "0750538219")
      expect(care_home).not_to be_valid
      expect(care_home.errors[:phone_number]).to include("must be a valid UK phone number")
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

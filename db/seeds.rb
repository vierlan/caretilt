# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# If a file has db:drop before you need to run this command before seeding
# rails local_authorities:import

# raise StandardError, "DO NOT RUN THIS IN PRODUCTION" if Rails.env.production?
def destroy_all
  puts "Destroying all records..."
  Subscription.destroy_all
  User.destroy_all
  Room.destroy_all
  CareHome.destroy_all
  Company.destroy_all
  Package.destroy_all
  LocalAuthority.destroy_all
  puts "All records destroyed."
end

# require 'seed_support/rewardful'

#SeedSupport::Rewardful.run

def create_packages
  Package.create(name: 'starter', price: 360, validity: 1, credits: 1, description: 'Starter package for one off listings', data: { lookup: 'starter' })
  Package.create(name: 'lite_monthly', price: 150, validity: 1, credits: 1, description: 'Lite package for monthly listings. Perfect for Small providers of 4 or more services who are likely to have less than 1 void / vacancy per month.', data: { lookup: 'lite_monthly' })
  Package.create(name: 'lite_yearly', price: 1500, validity: 12, credits: 10, description: 'Lite package for yearly listings. Perfect for Small providers of 4 or more services who are likely to have less than 1 void / vacancy per month.', data: { lookup: 'lite_yearly' })
  Package.create(name: 'pro_monthly', price: 300, validity: 1, credits: 4, description: 'Pro package for monthly listings. Medium providers of 10 or more services who are likely to have more than 3 voids a month. Small referral team or managed by registered managers . Typically work with more than 5 Local Authorities and probably specialist.', data: { lookup: 'pro_monthly' })
  Package.create(name: 'pro_yearly', price: 3000, validity: 12, credits: 50, description: 'Pro package for yearly listings. Medium providers of 10 or more services who are likely to have more than 3 voids a month. Small referral team or managed by registered managers . Typically work with more than 5 Local Authorities and probably specialist', data: { lookup: 'pro_yearly' })
  Package.create(name: 'unlimited_monthly', price: 600, validity: 1, credits: 100000, description: 'Unlimited package for monthly listings. Medium to Large providers who have regular voids/ vacancies. Referral team typically handles more than 10 referrals a month and work with more than 10 Local Authorities. ', data: { lookup: 'unlimited_monthly' })
  Package.create(name: 'unlimited_yearly', price: 6000, validity: 12, credits: 100000, description: 'Unlimited package for yearly listings.  Medium to Large providers who have regular voids/ vacancies. Referral team typically handles more than 10 referrals a month and work with more than 10 Local Authorities ', data: { lookup: 'unlimited_yearly' })
  Package.create(name: 'Add 3 credits', price: 690, validity: 0, credits: 5, description: 'Add 5 credits to your account', data: { lookup: 'add_5_credits' })
  Package.create(name: 'Local Authority Licence', price: 3000, validity: 12, credits: nil, description: 'Allows local Authorities workers to view vacancies in Local care home', data: { lookup: 'la_licence' }, subscription_type: 1 )

  @packages = Package.all

  @packages.each do |package|
    # for production, make sure that the stripe api key is accessible in the credentials file
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    service = StripePackage.new(package)
    case package.validity
    when 0
      service.create_add_credits_package
    else
      service.create_package
    end
  end
  puts "packages made"
end

# Used as reference to delete all seeded things when re-seeding.
def seed_entities
  # Creates or finds the main company, Caretilt
company1 = Company.find_or_create_by!(name: 'Care Tilt', email: 'placement@caretilt.co.uk', address1: "20-22 Wenlock Road", city: "London", postcode: , website: "http://www.caretilt.co.uk/")
end
# Users


def seed_super_users
  puts "Seeding super users..."
  irene_la_user = User.create!(
    email: 'irene@solorr.com',
    password: '123123',
    first_name: 'Irene',
    last_name: 'Tilt',
    role: 'administrator',
    status: 'verified',
    phone_number: ENV['IRENE_NUMBER'],
    verified: true,
    local_authority: localauthority
  )
  lan_caretilt_user = User.create!(
    email: 'caretilt@gmail.com',
    password: '123123',
    first_name: 'Lan Ahn',
    last_name: 'Tilt',
    role: 'super_admin',
    status: 'verified',
    phone_number: ENV['LAN_PHONE_NUMBER'],
    verified: true,
    company: company1,
    admin: true
  )

  madi_care_user = User.create!(
    email: 'maditurpin@gmail.com',
    password: '123123',
    first_name: 'Madi',
    last_name: 'Turpin',
    role: 'super_admin',
    status: 'verified',
    phone_number: ENV['MADI_NUMBER'],
    verified: true,
    company: company1,
    admin: true
  )


# Attach all homes to the created user (since the user must be associated with a company)
def seed_homes
care_homes = [
  { name: "Oak Lodge Medical Centre", main_contact: "Mr Oak", short_description: "Burnt Oak Care Home", email: "oaklodge@care.com", phone_number:"02084332000",
    long_description: "Welcome to Oak Lodge Medical Practice. Our website has been designed to make it easy for you to gain instant access to the information you need.",
    type_of_service: "Assisted Living / Sheltered", types_of_client_group: ["Learning Disabilities and/or Autism", "Mental Health and/or Autism"], local_authority_name: "London - City of London", latitude: 51.6043591, longitude: -0.2716591, address1: "234 Burnt Oak Broadway", address2: "Edgware", city: "Greater London", postcode: "HA80AP", website: "http://www.oaklodgemedicalcentre.co.uk/" },
  { name: "Ashton Lodge Care Home", main_contact: "Mr Ashton", short_description: "Ashton", long_description: "Ashton Lodge is a quality, purpose-built care home that offers specialist facilities.",
    type_of_service: "Nursing Home", types_of_client_group: ["Older People"], local_authority_name: "London - City of London", latitude: 51.5844218, longitude: -0.2486285, address1: "unknown", city: "Greater London", postcode: "NW96LE", address2: "" },
  { name: "Bridgeside Lodge", main_contact: "Mr Lodge", short_description: "Bridgeside Lodge", long_description: "Welcome to Bridgeside Lodge Care Home in Islington, London. Situated by the beautiful Regent’s Canal.",
    type_of_service: "Nursing Home", types_of_client_group: ["Older People"], local_authority_name: "Greater London", latitude: 51.5327147, longitude: -0.0970986, address1: "61 Wharf Road", address2: "London", city: "Greater London", postcode: "N17RY", website: "https://www.foresthc.com/our-care-centres/bridgeside-lodge" },
  { name: "MHA Hampton Lodge", main_contact: "Mr Hampton", short_description: "MHA Lodge", long_description: "Hampton Lodge in Southampton provides high-quality nursing and residential dementia care for up to 44 people.",
    type_of_service: "Dementia Care Home", types_of_client_group: ["Physical and/or Sensory Disabilities","Older People"], local_authority_name: "Southampton", latitude: 50.9122971, longitude: -1.4148484, address1: "33 Hill Lane", city: "Southampton", postcode: "SO155WF", website: "https://www.mha.org.uk/care-support/care-homes/hampton-lodge/", address2: "" },
  { name: "Brookvale House Care Home", main_contact: "Mrs Brookvale", short_description: "Brookvale", long_description: "Brookvale House is located in Portswood, Southampton, and offers an unrivalled programme of care and support.",
    type_of_service: "Semi Independent Living", types_of_client_group: ["Learning Disabilities and/or Autism", "Physical and/or Sensory Disabilities", "Older People"], local_authority_name: "Southampton", latitude: 50.9251556, longitude: -1.394676, address1: "4 Brookvale Road", city: "Southampton", postcode: "SO171QL", website: "http://www.brookvalehealthcare.co.uk/brookvale-care-home/", address2: "" },
  { name: "Mary & Joseph House", main_contact: "Mary", short_description: "Providing a safe, caring environment.", long_description: "Mary and Joseph House is proud to announce it is in the running for a prestigious national award.",
    type_of_service: "Hospice / EoL", types_of_client_group: ["Learning Disabilities and/or Autism", "Physical and/or Sensory Disabilities"], local_authority_name: "Manchester", latitude: 53.4812883, longitude: -2.2098852, address1: "217 Palmerston Street", city: "Greater Manchester", postcode: "M126PT", website: "http://maryandjosephhouse.co.uk/", address2: "" },
  { name: "Acacia Lodge Care Home - Avery Healthcare", main_contact: "Ms Acacia", short_description: "Assisted Living Residence", long_description: "Located in New Moston, we welcome you to meet Acacia Lodge’s friendly team.",
    type_of_service: "Assisted Living / Sheltered", types_of_client_group: ["Learning Disabilities and/or Autism", "Mental Health and/or Autism", "Older People"], local_authority_name: "Manchester", latitude: 53.517238, longitude: -2.1695793, address1: "90A Broadway", city: "Greater Manchester", postcode: "M403WQ", website: "https://www.averyhealthcare.co.uk/care-homes/manchester/acacia-lodge/", address2: "" },
  { name: "Greensleeves Care Home", main_contact: "Mr Sleeve", short_description: "Greensleeves", long_description: "Welcome to Greensleeves Care. We have been supporting older people for more than 25 years.",
    type_of_service: "Residential Care Home", types_of_client_group: ["Older People"], local_authority_name: "Crawley", latitude: 51.1105285, longitude: -0.1934223, address1: "19 Perryfield Road", city: "West Sussex", postcode: "RH118AA", website: "http://www.greensleevescarehome.co.uk/", address2: "" },
  { name: "Southern Counties Caring Ltd", main_contact: "Susan", short_description: "Hospice", long_description: "Southern Counties Caring is a growing care provider offering a full range of specialised home care services.",
    type_of_service: "Hospice / EoL", types_of_client_group: ["Learning Disabilities and/or Autism", "Children and Young People", "Children with SEN", "Young People / Unaccompanied Minors"], local_authority_name: "Crawley", latitude: 51.1135474, longitude: -0.1786974, address1: "Spindle Way", city: "West Sussex", postcode: "RH101TT", website: "http://www.southerncountiescaring.co.uk/", address2: "" }
]




puts "care home length array: #{care_homes.length}"

rooms = [
  {name: "Yellow", core_fee_level: 10, core_hours_of_care: 20, additional_fees_associated: false, ensuite: true, single_double: "Single Room", vacant: true},
  {name: "Blue", core_fee_level: 13, core_hours_of_care: 40, additional_fees_associated: true, ensuite: false, single_double: "Double Room", vacant: true},
  {name: "Pink", core_fee_level: 13, core_hours_of_care: 20, additional_fees_associated: true, ensuite: true, single_double: "Single Room", vacant: false},
  {name: "Magenta", core_fee_level: 16, core_hours_of_care: 40, additional_fees_associated: false, ensuite: true, single_double: "Double Room", vacant: false},
  {name: "Turquoise", core_fee_level: 100, core_hours_of_care: 40, additional_fees_associated: false, ensuite: false, single_double: "Single Room", vacant: true},
]


care_homes[0..2].each do |care_home_attrs|
  company1 = Company.first
  care_home = company1.care_homes.create!(care_home_attrs)

  # Randomly choose the number of rooms to create for each care home (between 0 and 5)
  number_of_rooms = rand(0..5)

  # Randomly select rooms from the rooms array
  rooms.sample(number_of_rooms).each do |room_attrs|
    care_home.rooms.create!(room_attrs)
  end
end

care_homes[3..8].each do |care_home_attrs|
  company2 = Company.last
  care_home = company2.care_homes.create!(care_home_attrs)

  # Randomly choose the number of rooms to create for each care home (between 0 and 5)
  number_of_rooms = rand(0..5)

  # Randomly select rooms from the rooms array
  rooms.sample(number_of_rooms).each do |room_attrs|
    care_home.rooms.create!(room_attrs)
  end
end
end

def run_all
  destroy_all
  seed_entities
  seed_super_users
end
run_all

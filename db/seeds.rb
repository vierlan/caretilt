# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# If a file has db:drop before you need to run this command before seeding
# rails local_authorities:import

raise StandardError, "DO NOT RUN THIS IN PRODUCTION" if Rails.env.production?

# require 'seed_support/rewardful'

#SeedSupport::Rewardful.run


Package.create(name: 'starter', price: 360, validity: 1, credits: 1, description: 'Starter package for one off listings', data: { lookup: 'starter' })
Package.create(name: 'lite_monthly', price: 150, validity: 1, credits: 1, description: 'Lite package for monthly listings', data: { lookup: 'lite_monthly' })
Package.create(name: 'lite_yearly', price: 1500, validity: 12, credits: 10, description: 'Lite package for yearly listings', data: { lookup: 'lite_yearly' })
Package.create(name: 'pro_monthly', price: 300, validity: 1, credits: 4, description: 'Pro package for monthly listings', data: { lookup: 'pro_monthly' })
Package.create(name: 'pro_yearly', price: 3000, validity: 12, credits: 50, description: 'Pro package for yearly listings', data: { lookup: 'pro_yearly' })
Package.create(name: 'unlimited_monthly', price: 600, validity: 1, credits: 100000, description: 'Unlimited package for monthly listings', data: { lookup: 'unlimited_monthly' })
Package.create(name: 'unlimited_yearly', price: 6000, validity: 12, credits: 100000, description: 'Unlimited package for yearly listings', data: { lookup: 'unlimited_yearly' })
Package.create(name: 'Add 5 credits', price: 290, validity: 0, credits: 5, description: 'Add 5 credits to your account', data: { lookup: 'add_5_credits' })

@packages = Package.all

@packages.each do |package|
  Stripe.api_key = Rails.application.credentials&.stripe&.api_key
  service = StripePackage.new(package)
  case package.validity
  when 0
    service.create_add_credits_package
  else
    service.create_package
  end
end

# Used as reference to delete all seeded things when re-seeding.
seeded_org_names = ['Care Provider Company']
seeded_user_email = ['com@test.com', 'la@test.com']
seeded_care_home_names = [
  "Oak Lodge Medical Centre",
  "Ashton Lodge Care Home",
  "Bridgeside Lodge",
  "MHA Hampton Lodge",
  "Brookvale House Care Home",
  "Mary & Joseph House",
  "Acacia Lodge Care Home - Avery Healthcare",
  "Greensleeves Care Home",
  "Southern Counties Caring Ltd"
]

puts "Deleting seeded users and care homes... \n"
User.where(email: seeded_user_email).destroy_all
CareHome.where(name: seeded_care_home_names).destroy_all
Company.where(name: seeded_org_names).destroy_all

# Create or find a company for the care provider user (if needed)
company = Company.find_or_create_by!(name: 'Care Provider Company')
localauthority = LocalAuthority.find_or_create_by!(name: 'Local Authority Organisation')
# careprovidersuperuser.company = company

# Users
careprovidersuperuser = User.create!(
  email: 'com@test.com',
  password: '123456',
  password_confirmation: '123456',
  first_name: 'Care',
  last_name: 'Provider',
  role: 'care_provider_super_user',
  status: 'verified',
  company: company,
  phone_number: ENV['PHONE_NUMBER'],
  verified: true
)

lasuperuser = User.create!(
    email: 'la@test.com',
    password: '123456',
    password_confirmation: '123456',
    first_name: 'Local',
    last_name: 'Authority',
    role: 'la_super_user',
    status: 'verified',
    local_authority: localauthority,
    phone_number: ENV['PHONE_NUMBER'],
    verified: true
  )

# Attach all homes to the created user (since the user must be associated with a company)

care_homes = [
  { name: "Oak Lodge Medical Centre", main_contact: "Mr Oak", short_description: "Burnt Oak Care Home", email: "oaklodge@care.com", phone_number:"02084332000",
    long_description: "Welcome to Oak Lodge Medical Practice With patients' needs at the heart of everything we do, our website has been designed to make it easy for you to gain instant access to the information you need. As well as specific practice details such as opening hours and how to register, you’ll find a wealth of useful pages covering a wide range of health issues along with links to other relevant medical organisations.",
    type_of_home: "Adult Homes", types_of_client_group: ["Learning Disabilities and/or Autism", "Mental Health and/or Autism"], local_authority_name: "London - City of London", latitude: 51.6043591, longitude: -0.2716591, address1: "234 Burnt Oak Broadway", address2: "Edgware", city: "Greater London", postcode: "HA80AP", website: "http://www.oaklodgemedicalcentre.co.uk/" },
  { name: "Ashton Lodge Care Home", main_contact: "Mr Ashton", short_description: "Ashton", long_description: "Ashton Lodge is a quality, purpose built care home that offers specialist facilities and care from highly trained staff. The home aims to maintain good links within the community to provide meaningful visits, trips and activities for the residents who can enjoy taking part in regular group events.
The home has an open door policy, encouraging family and friends to come to the home and spend time with their loved ones. Whether it is spending time in the resident’s private bedroom, in the garden or in communal lounges, residents are helped to see their loved ones regularly.", type_of_home: "Nursing Home", types_of_client_group: ["Older People"], local_authority_name: "London - City of London", latitude: 51.58442179999999, longitude: -0.2486285, address1: "unknown", city: "Greater London", postcode: "NW96LE", address2:"" },
  { name: "Bridgeside Lodge", main_contact: "Mr Lodge", short_description: "Bridgeside Lodge", long_description: "Welcome to Bridgeside Lodge Care Home in Islington, London. Situated by the beautiful Regent’s Canal, our luxurious modern gated care home offers 24-hour care for those between the ages of 18 to 65 and above. We provide specialist care for younger people with neurological and spinal conditions, and elderly people with or without Dementia. Our purpose-built nursing home comprises 64 single bedrooms, all with en-suite facilities.",
  type_of_home: "Nursing Home", types_of_client_group: ["Older People"], local_authority_name: "Greater London", latitude: 51.5327147, longitude: -0.09709860000000001, address1: "61 Wharf Road", address2: "London", city: "Greater London", postcode: "N17RY", website: "https://www.foresthc.com/our-care-centres/bridgeside-lodge"},
  { name: "MHA Hampton Lodge", main_contact: "Mr Hampton", short_description: "MHA Lodge", long_description: "Hampton Lodge in Southampton provides high quality nursing and residential dementia care for up to 44 people. We are passionate about our home and residents. We provide a warm and homely environment and treat all our residents as individuals who have the right to be given choice. Residents enjoy our calm, relaxed atmosphere and benefit from our person-centred care. At Hampton Lodge, we take time to get to know each individual’s history, personality and preferences, and find ways to make every day fulfilling. Our Activity Coordinator ensures residents are kept active and entertained with a variety of optional events and activities",
  type_of_home: "Nursing Home", types_of_client_group: ["Physical and/or Sensory Disabilities", "Older People"], local_authority_name: "Southampton", latitude: 50.91229709999999, longitude: -1.4148484, address1: "33 Hill Lane", city: "Southampton", postcode: "SO155WF", website: "https://www.mha.org.uk/care-support/care-homes/hampton-lodge/", address2:"" },
  { name: "Brookvale House Care Home", main_contact: "Mrs Brookvale", short_description: "Brookvale", long_description: "Brookvale House has been the mainstay of the Brookvale Healthcare group, having been the first home that operated under the Brookvale Healthcare banner all the way back in 1986.

Perfectly located in the centre of Portswood, Southampton, residents have access to a large variety of shops and amenities. Brookvale House is a relative oasis of calm. This environment allows us to offer an unrivalled programme of care, companionship and support with living, 24/7. This is aided by our homely, bespoke facilities which span two floors, as well as our recently upgraded sensory garden.", type_of_home: "Adult Homes", types_of_client_group: ["Learning Disabilities and/or Autism", "Physical and/or Sensory Disabilities", "Older People"], local_authority_name: "Southampton", latitude: 50.9251556, longitude: -1.394676, address1: "4 Brookvale Road", city: "Southampton", postcode: "SO171QL", website: "http://www.brookvalehealthcare.co.uk/brookvale-care-home/", address2:"" },
  { name: "Mary & Joseph House", main_contact: "Mary", short_description: "Our aim is to provide a safe, caring and stable environment to gentlemen looking to get back on their feet after alcohol dependency and mental health difficulties.", long_description: "Mary and Joseph House is proud to announce that it is in the running for a prestigious national award, The homes Activity Team has been shortlisted in the the Caring UK Awards, which recognise excellence and achievement within the care sector across the UK. An awards spokesperson said: “Never has there been a more appropriate time to recognise the amazing and selfless contribution that our carers make and how they have given so much to protect and care for their residents in the face of unprecedented challenges.", type_of_home: "Assisted Living", types_of_client_group: ["Learning Disabilities and/or Autism", "Physical and/or Sensory Disabilities"], local_authority_name: "Manchester", latitude: 53.4812883, longitude: -2.2098852, address1: "217 Palmerston Street", city: "Greater Manchester", postcode: "M126PT", website: "http://maryandjosephhouse.co.uk/", address2:"" },
  { name: "Acacia Lodge Care Home - Avery Healthcare", main_contact: "Ms Acacia", short_description: "Assisted Living Residence", long_description: "Located in the suburbs of New Moston, we welcome you to meet Acacia Lodge’s friendly Home Manager and team for complimentary refreshments  in one of our  visiting rooms or luscious garden area. Alternatively, call us to learn about the facilities at our care home in Manchester and discuss your care needs. Whether you’re looking for person-centric dementia care in Manchester or short term respite care, we’re happy to discuss our care plans with you today.", type_of_home: "Assisted Living", types_of_client_group: ["Learning Disabilities and/or Autism", "Mental Health and/or Autism", "Older People"], local_authority_name: "Manchester", latitude: 53.517238, longitude: -2.169579300000001, address1: "90A Broadway", city: "Greater Manchester", postcode: "M403WQ", website: "https://www.averyhealthcare.co.uk/care-homes/manchester/acacia-lodge/", address2:"" },
  { name: "Greensleeves Care Home", main_contact: "Mr Sleeve", short_description: "Greensleeves", long_description: "Welcome to Greensleeves Care
We have been supporting older people for more than 25 years.

We are a family of 28 not-for-profit care homes across England. We support our residents and their loved ones with award-winning residential, dementia and nursing care.", type_of_home: "Adult Homes", types_of_client_group: ["Older People"], local_authority_name: "Crawley", latitude: 51.11052850000001, longitude: -0.1934223, address1: "19 Perryfield Road", city: "West Sussex", postcode: "RH118AA", website: "http://www.greensleevescarehome.co.uk/", address2:"" },
  { name: "Southern Counties Caring Ltd", main_contact: "Susan", short_description: "Hospice", long_description: "Southern Counties Caring is a growing care provider offering a full range of specialised home care services designed to meet your unique care requirements. We pride ourselves on our dignified approach, treating every client with compassion and kindness to deliver the best possible care service, all in the comfort of your own home.",
  type_of_home: "Hospice Homes", types_of_client_group: ["Learning Disabilities and/or Autism", "Children and Young People", "Children with SEN", "Young People / Unaccompanied Minors"], local_authority_name: "Crawley", latitude: 51.1135474, longitude: -0.1786974, address1: "Spindle Way", city: "West Sussex", postcode: "RH101TT", website: "http://www.southerncountiescaring.co.uk/", address2:"" }
]

rooms = [
  {name: "Yellow", core_fee_level: 10, core_hours_of_care: 20, additional_fees_associated: false, ensuite: true, single_double: "Single Room", vacant: true},
  {name: "Blue", core_fee_level: 13, core_hours_of_care: 40, additional_fees_associated: true, ensuite: false, single_double: "Double Room", vacant: true},
  {name: "Pink", core_fee_level: 13, core_hours_of_care: 20, additional_fees_associated: true, ensuite: true, single_double: "Single Room", vacant: false},
  {name: "Magenta", core_fee_level: 16, core_hours_of_care: 40, additional_fees_associated: false, ensuite: true, single_double: "Double Room", vacant: false},
  {name: "Turquoise", core_fee_level: 100, core_hours_of_care: 40, additional_fees_associated: false, ensuite: false, single_double: "Single Room", vacant: true},
]


care_homes.each do |care_home_attrs|
  care_home = company.care_homes.create!(care_home_attrs)

  # Randomly choose the number of rooms to create for each care home (between 0 and 5)
  number_of_rooms = rand(0..5)

  # Randomly select rooms from the rooms array
  rooms.sample(number_of_rooms).each do |room_attrs|
    care_home.rooms.create!(room_attrs)
  end
end

puts 'Seeded care homes and associated them with the care provider super user.'
puts 'Randomly assigned rooms to each care home.'

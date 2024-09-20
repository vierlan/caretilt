# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

raise StandardError, "DO NOT RUN THIS IN PRODUCTION" if Rails.env.production?

require 'seed_support/rewardful'

SeedSupport::Rewardful.run


Package.create(name: 'starter',  price: 360, validity: 1, credits: 1)
Package.create(name: 'lite_monthly',  price: 150, validity: 1, credits: 10)
Package.create(name: 'lite_yearly',  price: 1500, validity: 12, credits: 10)
Package.create(name: 'pro_monthly',  price: 300, validity: 1, credits: 50)
Package.create(name: 'pro_yearly',  price: 3000, validity: 12, credits: 50)
Package.create(name: 'unlimited_monthly',  price: 600, validity: 1, credits: 100000)
Package.create(name: 'unlimited_yearly',  price: 6000, validity: 12, credits: 100000)


# Used as reference to delete all seeded things when re-seeding.
seeded_company_names = ['Care Provider Company']
seeded_user_email = ['careprovidersuperuser@test.com', 'lasuperuser@test.com']
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

# puts "Deleting seeded users and care homes..."
# User.where(email: seeded_user_email).destroy_all
# CareHome.where(name: seeded_care_home_names).destroy_all
# Company.where(name: seeded_company_names).destroy_all

# Users
careprovidersuperuser = User.create!(
  email: 'careprovidersuperuser@test.com',
  password: '123456',
  password_confirmation: '123456',
  first_name: 'Care',
  last_name: 'Provider',
  role: 'care_provider_super_user',
  status: 'verified'
)

lasuperuser = User.create!(
    email: 'lasuperuser@test.com',
    password: '123456',
    password_confirmation: '123456',
    first_name: 'Local',
    last_name: 'Authority',
    role: 'la_super_user',
    status: 'verified'
    )

# Create or find a company for the care provider user (if needed)
company = Company.find_or_create_by!(name: 'Care Provider Company')
careprovidersuperuser.company = company

# Attach all homes to the created user (since the user must be associated with a company)

care_homes = [
  { name: "Oak Lodge Medical Centre", main_contact: "Mr Oak", short_description: "Burnt Oak Care Home", type_of_home: "Adult Homes", types_of_client_group: ["Learning Disabilities and/or Autism", "Mental Health and/or Autism"], local_authority_name: "City of London", latitude: 51.6043591, longitude: -0.2716591, address1: "234 Burnt Oak Broadway", address2: "Edgware", city: "Greater London", postcode: "HA80AP", website: "http://www.oaklodgemedicalcentre.co.uk/" },
  { name: "Ashton Lodge Care Home", main_contact: "Mr Ashton", short_description: "Ashton", type_of_home: "Nursing Home", types_of_client_group: ["Older People"], local_authority_name: "City of London", latitude: 51.58442179999999, longitude: -0.2486285, address1: "unknown", city: "Greater London", postcode: "NW96LE" },
  { name: "Bridgeside Lodge", main_contact: "Mr Lodge", short_description: "Bridgeside Lodge", type_of_home: "Nursing Home", types_of_client_group: ["Older People"], local_authority_name: "Greater London", latitude: 51.5327147, longitude: -0.09709860000000001, address1: "61 Wharf Road", address2: "London", city: "Greater London", postcode: "N17RY", website: "https://www.foresthc.com/our-care-centres/bridgeside-lodge" },
  { name: "MHA Hampton Lodge", main_contact: "Mr Hampton", short_description: "MHA Lodge", type_of_home: "Nursing Home", types_of_client_group: ["Physical and/or Sensory Disabilities", "Older People"], local_authority_name: "Southampton", latitude: 50.91229709999999, longitude: -1.4148484, address1: "33 Hill Lane", city: "Southampton", postcode: "SO155WF", website: "https://www.mha.org.uk/care-support/care-homes/hampton-lodge/" },
  { name: "Brookvale House Care Home", main_contact: "Mrs Brookvale", short_description: "Brookvale", type_of_home: "Adult Homes", types_of_client_group: ["Learning Disabilities and/or Autism", "Physical and/or Sensory Disabilities", "Older People"], local_authority_name: "Southampton", latitude: 50.9251556, longitude: -1.394676, address1: "4 Brookvale Road", city: "Southampton", postcode: "SO171QL", website: "http://www.brookvalehealthcare.co.uk/brookvale-care-home/" },
  { name: "Mary & Joseph House", main_contact: "Mary", short_description: "Mary And Joseph", type_of_home: "Assisted Living", types_of_client_group: ["Learning Disabilities and/or Autism", "Physical and/or Sensory Disabilities"], local_authority_name: "Manchester", latitude: 53.4812883, longitude: -2.2098852, address1: "217 Palmerston Street", city: "Greater Manchester", postcode: "M126PT", website: "http://maryandjosephhouse.co.uk/" },
  { name: "Acacia Lodge Care Home - Avery Healthcare", main_contact: "Ms Acacia", short_description: "Assisted Living Residence", type_of_home: "Assisted Living", types_of_client_group: ["Learning Disabilities and/or Autism", "Mental Health and/or Autism", "Older People"], local_authority_name: "Manchester", latitude: 53.517238, longitude: -2.169579300000001, address1: "90A Broadway", city: "Greater Manchester", postcode: "M403WQ", website: "https://www.averyhealthcare.co.uk/care-homes/manchester/acacia-lodge/" },
  { name: "Greensleeves Care Home", main_contact: "Mr Sleeve", short_description: "Greensleeves", type_of_home: "Adult Homes", types_of_client_group: ["Older People"], local_authority_name: "Crawley", latitude: 51.11052850000001, longitude: -0.1934223, address1: "19 Perryfield Road", city: "West Sussex", postcode: "RH118AA", website: "http://www.greensleevescarehome.co.uk/" },
  { name: "Southern Counties Caring Ltd", main_contact: "Susan", short_description: "Hospice", type_of_home: "Hospice Homes", types_of_client_group: ["Learning Disabilities and/or Autism", "Children and Young People", "Children with SEN", "Young People / Unaccompanied Minors"], local_authority_name: "Crawley", latitude: 51.1135474, longitude: -0.1786974, address1: "Spindle Way", city: "West Sussex", postcode: "RH101TT", website: "http://www.southerncountiescaring.co.uk/" }
]

care_homes.each do |care_home_attrs|
    company.care_homes.create!(care_home_attrs)
end

puts 'Seeded care homes and associated them with the care provider super user.'

#<User id: 5, email: "la@test.com", created_at: "2024-09-18 19:09:59.098579000 +0000", updated_at: "2024-09-18 19:10:08.791692000 +0000", admin: false, stripe_customer_id: nil, paying_customer: false, stripe_subscription_id: nil, first_name: "local", last_name: "authority", role: "la_super_user", latitude: nil, longitude: nil, company_id: nil, local_authority_id: nil, care_home_id: nil, status: "not_verified">



# [#<CareHome:0x00007ff1588929d8
# id: 9,
# name: "Oak Lodge Medical Centre",
# address: nil,
# phone_number: "02089521202",
# main_contact: "mr oak",
# short_description: "Burnt Oak Care Home",
# long_description: nil,
# type_of_home: "Adult Homes",
# types_of_client_group: ["Learning Disabilities and/or Autism", "Mental Health and/or Autism"],
# company_id: 1,
# latitude: 51.6043591,
# longitude: -0.2716591,
# created_at: "2024-09-20 00:07:30.791097000 +0000",
# updated_at: "2024-09-20 00:07:30.791097000 +0000",
# email: "",
# website: "http://www.oaklodgemedicalcentre.co.uk/",
# address1: "234 Burnt Oak Broadway",
# address2: "Edgware",
# city: "Greater London",
# postcode: "HA80AP",
# county: nil,
# country: nil,
# local_authority_name: "City of London">,
# #<CareHome:0x00007ff158883fc8
# id: 10,
# name: "Ashton Lodge Care Home",
# address: nil,
# phone_number: "02087327260",
# main_contact: "Mr Ashton",
# short_description: "Ashton",
# long_description: nil,
# type_of_home: "Nursing Home",
# types_of_client_group: ["Older People"],
# company_id: 1,
# latitude: 51.58442179999999,
# longitude: -0.2486285,
# created_at: "2024-09-20 00:08:33.416736000 +0000",
# updated_at: "2024-09-20 00:08:33.416736000 +0000",
# email: "",
# website: "",
# address1: "",
# address2: "London",
# city: "Greater London",
# postcode: "NW96LE",
# county: nil,
# country: nil,
# local_authority_name: "City of London">,
# #<CareHome:0x00007ff158883e88
# id: 11,
# name: "Bridgeside Lodge",
# address: nil,
# phone_number: "02072500156",
# main_contact: "Mr Lodge",
# short_description: "Bridgeside Lodge",
# long_description: nil,
# type_of_home: "Nursing Home",
# types_of_client_group: ["Older People"],
# company_id: 1,
# latitude: 51.5327147,
# longitude: -0.09709860000000001,
# created_at: "2024-09-20 00:15:07.194271000 +0000",
# updated_at: "2024-09-20 00:15:07.194271000 +0000",
# email: "",
# website: "https://www.foresthc.com/our-care-centres/bridgesi...",
# address1: "61 Wharf Road",
# address2: "London",
# city: "Greater London",
# postcode: "N17RY",
# county: nil,
# country: nil,
# local_authority_name: "Greater London">,
# #<CareHome:0x00007ff158883d48
# id: 12,
# name: "MHA Hampton Lodge",
# address: nil,
# phone_number: "02382597699",
# main_contact: "Mr Hampton",
# short_description: "MHA Lodge",
# long_description: nil,
# type_of_home: "Nursing Home",
# types_of_client_group: ["Physical and/or Sensory Disabilities", "Older People"],
# company_id: 1,
# latitude: 50.91229709999999,
# longitude: -1.4148484,
# created_at: "2024-09-20 00:26:45.482653000 +0000",
# updated_at: "2024-09-20 00:26:45.482653000 +0000",
# email: "",
# website: "https://www.mha.org.uk/care-support/care-homes/ham...",
# address1: "33 Hill Lane",
# address2: "Southampton",
# city: "Southampton",
# postcode: "SO155WF",
# county: nil,
# country: nil,
# local_authority_name: "Southampton">,
# #<CareHome:0x00007ff158883c08
# id: 13,
# name: "Brookvale House Care Home",
# address: nil,
# phone_number: "02380322541",
# main_contact: "Mrs Brookvale",
# short_description: "Brookvale",
# long_description: nil,
# type_of_home: "Adult Homes",
# types_of_client_group:
#  ["Learning Disabilities and/or Autism", "Physical and/or Sensory Disabilities", "Older People"],
# company_id: 1,
# latitude: 50.9251556,
# longitude: -1.394676,
# created_at: "2024-09-20 00:28:25.446269000 +0000",
# updated_at: "2024-09-20 00:28:25.446269000 +0000",
# email: "",
# website: "http://www.brookvalehealthcare.co.uk/brookvale-car...",
# address1: "4 Brookvale Road",
# address2: "Southampton",
# city: "Southampton",
# postcode: "SO171QL",
# county: nil,
# country: nil,
# local_authority_name: "Southampton">,
# #<CareHome:0x00007ff158883ac8
# id: 14,
# name: "Mary & Joseph House",
# address: nil,
# phone_number: "01612736881",
# main_contact: "Mary ",
# short_description: "Mary And Joseph",
# long_description: nil,
# type_of_home: "Assisted Living",
# types_of_client_group: ["Learning Disabilities and/or Autism", "Physical and/or Sensory Disabilities"],
# company_id: 1,
# latitude: 53.4812883,
# longitude: -2.2098852,
# created_at: "2024-09-20 00:30:17.735623000 +0000",
# updated_at: "2024-09-20 00:30:17.735623000 +0000",
# email: "",
# website: "http://maryandjosephhouse.co.uk/",
# address1: "217 Palmerston Street",
# address2: "Manchester",
# city: "Greater Manchester",
# postcode: "M126PT",
# county: nil,
# country: nil,
# local_authority_name: "Manchester">,
# #<CareHome:0x00007ff158883988
# id: 15,
# name: "Acacia Lodge Care Home - Avery Healthcare",
# address: nil,
# phone_number: "01616881890",
# main_contact: "Ms Acacia",
# short_description: "Assisted Living Residence",
# long_description: nil,
# type_of_home: "Assisted Living",
# types_of_client_group: ["Learning Disabilities and/or Autism", "Mental Health and/or Autism", "Older People"],
# company_id: 1,
# latitude: 53.517238,
# longitude: -2.169579300000001,
# created_at: "2024-09-20 00:31:44.102790000 +0000",
# updated_at: "2024-09-20 00:31:44.102790000 +0000",
# email: "",
# website: "https://www.averyhealthcare.co.uk/care-homes/manch...",
# address1: "90A Broadway",
# address2: "Manchester",
# city: "Greater Manchester",
# postcode: "M403WQ",
# county: nil,
# country: nil,
# local_authority_name: "Manchester">,
# #<CareHome:0x00007ff158883708
# id: 16,
# name: "Greensleeves Care Home",
# address: nil,
# phone_number: "01293511394",
# main_contact: "Mr Sleeve",
# short_description: "Greensleeves",
# long_description: nil,
# type_of_home: "Adult Homes",
# types_of_client_group: ["Older People"],
# company_id: 1,
# latitude: 51.11052850000001,
# longitude: -0.1934223,
# created_at: "2024-09-20 00:33:14.278452000 +0000",
# updated_at: "2024-09-20 00:33:14.278452000 +0000",
# email: "",
# website: "http://www.greensleevescarehome.co.uk/",
# address1: "19 Perryfield Road",
# address2: "Crawley",
# city: "West Sussex",
# postcode: "RH118AA",
# county: nil,
# country: nil,
# local_authority_name: "Crawley">,
# #<CareHome:0x00007ff1588835c8
# id: 17,
# name: "Southern Counties Caring Ltd",
# address: nil,
# phone_number: "08000025420",
# main_contact: "Susan",
# short_description: "Hospice",
# long_description: nil,
# type_of_home: "Hospice Homes",
# types_of_client_group:
#  ["Learning Disabilities and/or Autism", "Children and Young People", "Children with SEN", "Young People / Unaccompanied Minors"],
# company_id: 1,
# latitude: 51.1135474,
# longitude: -0.1786974,
# created_at: "2024-09-20 00:35:00.617673000 +0000",
# updated_at: "2024-09-20 00:35:00.617673000 +0000",
# email: "",
# website: "http://www.southerncountiescaring.co.uk/",
# address1: "Spindle Way",
# address2: "Crawley",
# city: "West Sussex",
# postcode: "RH101TT",
# county: nil,
# country: nil,
# local_authority_name: "Crawley">]
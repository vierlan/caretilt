# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# If a file has db:drop before you need to run this command before seeding
# rails local_authorities:import

# raise StandardError, "DO NOT RUN THIS IN PRODUCTION" if Rails.env.production?
def destroy_all
  puts "Destroying all records..."
  User.destroy_all
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
company1 = Company.find_or_create_by!(name: 'Care Tilt', email: 'placement@caretilt.co.uk', address1: "20-22 Wenlock Road", city: "London", website: "http://www.caretilt.co.uk/")

  puts "Seeding super users..."
  irene_la_user = User.create!(
    email: 'irene@solorr.com',
    password: '$Caretilt123',
    first_name: 'Irene',
    last_name: 'Tilt',
    role: 'administrator',
    status: 'verified',
    phone_number: ENV['IRENE_NUMBER'],
    verified: true,
    company: company1
  )
  lan_caretilt_user = User.create!(
    email: 'caretilt@gmail.com',
    password: '$Caretilt123',
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
    password: '$Caretilt123',
    first_name: 'Madi',
    last_name: 'Turpin',
    role: 'super_admin',
    status: 'verified',
    phone_number: ENV['MADI_NUMBER'],
    verified: true,
    company: company1,
    admin: true
  )

end

def run_all
  destroy_all
  seed_entities
end
run_all

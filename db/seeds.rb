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

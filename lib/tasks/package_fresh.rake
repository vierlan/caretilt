task :fresh_packages => :environment do
  # use after dropping data for packages to avoid bugs with associations
  Subscription.delete_all
  Package.delete_all
  companies = Company.all
  companies.each do |company|
    company.setup_stripe_customer
    company.stripe_subscription_id = nil
    company.save
  end
  local_authorities = LocalAuthority.all
  local_authorities.each do |local_authority|
    local_authority.setup_stripe_customer
    local_authority.stripe_subscription_id = nil
    local_authority.save
  end
end

# enable after improving 'finished_onboarding' logic
# task :offer_setup_assistance => :environment do
#   User.subscribed.where(created_at: 48.hours.ago..47.hours.ago).each do |user|
#     next if user.finished_onboarding?
#     UserMailer.offer_setup_assistance(user).deliver_later
#   end
# end

# enable if Stripe subscriptions exist
# task :sync_with_stripe => :environment do
#   User.subscribed.each do |user|
#     subscription = Stripe::Subscription.retrieve(user.stripe_subscription_id)
#     user.update(paying_customer: false) unless ['trialing', 'active', 'past_due'].include?(subscription.status)
#   end
# end

#Stripe::Product.list.each do |product|
#  package = Package.create(
#    name: product.name,
#    description: product.description,
#    credits: product.metadata['credits'],
#    stripe_id: product.id,
#    data: product.to_json
#  )
#  Rails.logger.info("Package created: #{package.name}")
#end

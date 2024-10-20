require_relative 'config/environment'

@subscriptions = Subscription.all

@subscriptions.each do |subscription|
  subscription.set_next_payment_date
  puts "Next payment date for subscription #{subscription.id} set to #{subscription.next_payment_date}"
end

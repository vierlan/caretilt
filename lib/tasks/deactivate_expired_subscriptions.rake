namespace :subscriptions do
  desc "Deactivate expired subscriptions"
  task deactivate_expired: :environment do
    Subscription.where('expires_on <= ?', Date.today).where(active: true).find_each do |subscription|
      subscription.deactivate!
      puts "Deactivated subscription ##{subscription.id}"
    end
  end
end

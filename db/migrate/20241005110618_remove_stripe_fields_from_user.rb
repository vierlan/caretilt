class RemoveStripeFieldsFromUser < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :stripe_customer_id
    remove_column :users, :paying_customer
    remove_column :users, :stripe_subscription_id
    remove_column :users, :latitude
    remove_column :users, :longitude
  end
end

class AddStripeFieldsToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :stripe_subscription_id, :string
    add_column :companies, :paying_customer, :boolean
  end
end

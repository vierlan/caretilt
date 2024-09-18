class AddStripeIdToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :stripe_customer_id, :string
  end
end

class AddStripeFieldsToPackages < ActiveRecord::Migration[7.2]
  def change
    add_column :packages, :stripe_id, :string
    add_column :packages, :data, :jsonb
    add_column :packages, :stripe_price_id, :string
    add_column :packages, :description, :text
  end
end

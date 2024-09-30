class AddSubscriptionTypeToPackages < ActiveRecord::Migration[7.2]
  def change
    add_column :packages, :subscription_type, :integer, default: 0, null: false  # Default to 'company'
  end
end

class AddFieldsToLocalAuthorities < ActiveRecord::Migration[7.2]
  def change
    add_column :local_authorities, :email, :string
    add_column :local_authorities, :stripe_customer_id, :string
    add_column :local_authorities, :stripe_subscription_id, :string
  end
end

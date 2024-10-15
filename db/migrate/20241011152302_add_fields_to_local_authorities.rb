class AddFieldsToLocalAuthorities < ActiveRecord::Migration[7.2]
  def change
    add_column :local_authorities, :email, :string unless column_exists?(:local_authorities, :email)
    add_column :local_authorities, :stripe_customer_id, :string unless column_exists?(:local_authorities, :stripe_customer_id)
    add_column :local_authorities, :stripe_subscription_id, :string unless column_exists?(:local_authorities, :stripe_subscription_id)
  end
end


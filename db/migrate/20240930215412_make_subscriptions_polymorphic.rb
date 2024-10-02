class MakeSubscriptionsPolymorphic < ActiveRecord::Migration[7.2]
  def change
    remove_index :subscriptions, :company_id

    rename_column :subscriptions, :company_id, :subscribable_id
    add_column :subscriptions, :subscribable_type, :string

    add_index :subscriptions, [:subscribable_type, :subscribable_id]
  end
end

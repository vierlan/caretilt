class RemoveForeignKeyOnSubscribableIdFromSubscriptions < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :subscriptions, :companies, column: :subscribable_id
  end
end

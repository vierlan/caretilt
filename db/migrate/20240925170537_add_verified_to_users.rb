class AddVerifiedToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :verified, :boolean
  end
end

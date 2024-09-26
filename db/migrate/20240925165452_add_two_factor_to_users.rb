class AddTwoFactorToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :two_factor_enabled, :boolean
  end
end

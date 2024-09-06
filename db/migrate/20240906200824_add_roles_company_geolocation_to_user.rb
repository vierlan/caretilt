class AddRolesCompanyGeolocationToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :role, :integer, default: 0
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
    add_reference :users, :company, foreign_key: true, null: true
    add_reference :users, :local_authority, foreign_key: true, null: true
  end
end

class AddAddressFieldsToCareHome < ActiveRecord::Migration[7.2]
  def change
    add_column :care_homes, :address1, :string, null: false
    add_column :care_homes, :address2, :string, null: false
    add_column :care_homes, :city, :string, null: false
    add_column :care_homes, :postcode, :string, null: false
    add_column :care_homes, :county, :string
    add_column :care_homes, :country, :string
  end
end

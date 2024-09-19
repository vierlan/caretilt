class AddAddressFieldsToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :address1, :string
    add_column :companies, :address2, :string
    add_column :companies, :city, :string
    add_column :companies, :postcode, :string
    add_column :companies, :country, :string
  end
end

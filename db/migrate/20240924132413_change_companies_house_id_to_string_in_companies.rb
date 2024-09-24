class ChangeCompaniesHouseIdToStringInCompanies < ActiveRecord::Migration[7.2]
  def change
    change_column :companies, :companies_house_id, :string
  end
end

class AddWebsiteToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :website, :string
  end
end

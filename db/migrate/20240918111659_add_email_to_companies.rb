class AddEmailToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :email, :string
    add_column :companies, :contact_name, :string
  end
end

class CreateCompanies < ActiveRecord::Migration[7.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :type
      t.integer :companies_house_id
      t.string :registered_address
      t.string :phone_number
      t.string :billing_address

      t.timestamps
    end
  end
end

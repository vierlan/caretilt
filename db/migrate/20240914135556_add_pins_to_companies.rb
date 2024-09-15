class AddPinsToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :registration_pin, :string, null: false, default: rand(1000..9999).to_s
    add_column :companies, :super_pin, :string, null: false, default: rand(1000..9999).to_s
  end
end

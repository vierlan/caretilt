class AddFormattedAddressToCareHomes < ActiveRecord::Migration[7.2]
  def change
    add_column :care_homes, :formatted_address, :string
  end
end

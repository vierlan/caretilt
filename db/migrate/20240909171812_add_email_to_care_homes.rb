class AddEmailToCareHomes < ActiveRecord::Migration[7.2]
  def change
    add_column :care_homes, :email, :string
  end
end

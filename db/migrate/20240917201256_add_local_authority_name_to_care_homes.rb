class AddLocalAuthorityNameToCareHomes < ActiveRecord::Migration[7.2]
  def change
    add_column :care_homes, :local_authority_name, :string
  end
end

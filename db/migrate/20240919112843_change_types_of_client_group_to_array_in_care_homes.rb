class ChangeTypesOfClientGroupToArrayInCareHomes < ActiveRecord::Migration[7.2]
  def change
    change_column :care_homes, :types_of_client_group, :string, array: true, default: [], using: "(string_to_array(types_of_client_group, ','))"
  end
end

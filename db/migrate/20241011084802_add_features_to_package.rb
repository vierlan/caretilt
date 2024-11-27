class AddFeaturesToPackage < ActiveRecord::Migration[7.2]
  def change
    add_column :packages, :features, :string, array: true, default: []
  end
end

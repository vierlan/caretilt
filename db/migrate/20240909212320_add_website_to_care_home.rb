class AddWebsiteToCareHome < ActiveRecord::Migration[7.2]
  def change
    add_column :care_homes, :website, :string
  end
end

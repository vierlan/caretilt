class AddVacantToRooms < ActiveRecord::Migration[7.2]
  def change
    add_column :rooms, :vacant, :boolean, default: false
  end
end

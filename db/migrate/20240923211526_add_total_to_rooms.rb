class AddTotalToRooms < ActiveRecord::Migration[7.2]
  def change
    add_column :rooms, :total, :decimal, precision: 10, scale: 2
  end
end

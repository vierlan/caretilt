class AddForeignKeyToUsers < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :care_home, foreign_key: true
  end
end

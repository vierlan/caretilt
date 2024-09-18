class CreatePackages < ActiveRecord::Migration[7.2]
  def change
    create_table :packages do |t|
      t.string :name
      t.integer :validity
      t.integer :credits
      t.integer :price

      t.timestamps
    end
  end
end

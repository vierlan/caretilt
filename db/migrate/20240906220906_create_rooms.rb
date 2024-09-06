class CreateRooms < ActiveRecord::Migration[7.2]
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer :core_fee_level
      t.integer :core_hours_of_care
      t.boolean :additional_fees_associated
      t.jsonb :other_data
      t.string :single_double
      t.boolean :ensuite
      t.references :care_home, null: false, foreign_key: true
      t.timestamps
    end
  end
end

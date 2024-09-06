class CreateCareHomes < ActiveRecord::Migration[7.2]
  def change
    create_table :care_homes do |t|
      t.string :name
      t.jsonb :address
      t.string :phone_number
      t.string :main_contact
      t.text :short_description
      t.text :long_description
      t.string :type_of_home
      t.string :types_of_client_group
      t.references :company, null: false, foreign_key: true
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end

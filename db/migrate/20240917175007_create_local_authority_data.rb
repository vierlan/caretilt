class CreateLocalAuthorityData < ActiveRecord::Migration[7.2]
  def change
    create_table :local_authority_data do |t|
      t.string :local_authority_code
      t.string :official_name
      t.string :nice_name

      t.timestamps
    end
  end
end

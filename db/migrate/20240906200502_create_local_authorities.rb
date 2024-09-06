class CreateLocalAuthorities < ActiveRecord::Migration[7.2]
  def change
    create_table :local_authorities do |t|
      t.string :name

      t.timestamps
    end
  end
end

class CreateBookingEnquiries < ActiveRecord::Migration[7.2]
  def change
    create_table :booking_enquiries do |t|
      t.string :contact_name
      t.string :phone_number
      t.string :service_user_name
      t.text :message
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end

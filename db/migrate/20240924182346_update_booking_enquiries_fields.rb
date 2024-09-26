class UpdateBookingEnquiriesFields < ActiveRecord::Migration[6.1]
  def change
    # Renaming columns
    rename_column :booking_enquiries, :service_user_name, :reference_name

    # Adding new email column
    add_column :booking_enquiries, :email, :string
  end
end

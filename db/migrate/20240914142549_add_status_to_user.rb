class AddStatusToUser < ActiveRecord::Migration[7.2]
  def up
    # Step 1: Add the new status column as integer for enum
    add_column :users, :status, :integer, default: 0, null: false

    # Step 2: Migrate the existing verified data to the new status column
    User.reset_column_information
    User.where(verified: true).update_all(status: 2)   # Set status to 'verified' (2) where verified is true
    User.where(verified: false).update_all(status: 0)  # Set status to 'added' (0) where verified is false

    # Step 3: Remove the old verified boolean column
    remove_column :users, :verified, :boolean if column_exists?(:users, :verified)
  end

  def down
    # Step 4: Revert to the old verified boolean column
    add_column :users, :verified, :boolean, default: false

    # Step 5: Migrate the new status values back to the verified boolean column
    User.reset_column_information
    User.where(status: 2).update_all(verified: true)   # Set verified to true where status is 'verified' (2)
    User.where(status: 0).update_all(verified: false)  # Set verified to false where status is 'added' (0)

    # Step 6: Remove the status column
    remove_column :users, :status, :integer
  end
end

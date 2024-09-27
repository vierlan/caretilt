class AddPostionColumnToActiveStorageAttachments < ActiveRecord::Migration[7.2]
  def change
    add_column :active_storage_attachments, :position, :integer
  end
end

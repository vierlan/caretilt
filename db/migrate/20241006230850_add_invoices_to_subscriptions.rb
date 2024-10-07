class AddInvoicesToSubscriptions < ActiveRecord::Migration[7.2]
  def change
    add_column :subscriptions, :invoices, :string, array: true, default: []
  end
end

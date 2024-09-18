class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.string :receipt_number
      t.date :expires_on
      t.integer :credits_left
      t.string :credit_log, array: true, default: []
      t.date :next_payment_date
      t.boolean :active
      t.date :subscribed_on
      t.integer :number_of_payments
      t.references :company, null: false, foreign_key: true
      t.references :package, null: false, foreign_key: true

      t.timestamps
    end
  end
end

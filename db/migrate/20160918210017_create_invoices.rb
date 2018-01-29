class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.integer :user_id
      t.string :stripe_id
      t.integer :amount
      t.string :currency
      t.string :number
      t.datetime :paid_at
      t.text :lines

      t.timestamps null: false
    end

    add_index :invoices, :stripe_id, unique: true
  end
end

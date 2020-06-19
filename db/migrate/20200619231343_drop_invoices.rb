class DropInvoices < ActiveRecord::Migration[6.0]
  def up
    drop_table :invoices
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

class CreatePlansAgain < ActiveRecord::Migration[6.0]
  def change
    remove_column :products, :amount, :integer

    create_table :plans do |t|
      t.belongs_to :product
      t.string :name, null: false
      t.integer :amount, null: false
      t.string :currency, null: false, default: "USD"
      t.string :interval, null: false, default: "month"
      t.string :stripe_id
    end
  end
end

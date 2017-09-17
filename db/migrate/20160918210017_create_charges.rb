class CreateCharges < ActiveRecord::Migration[5.0]
  def change
    create_table :charges do |t|
      t.integer :user_id
      t.string :stripe_id
      t.integer :amount
      t.string :card_last4
      t.string :card_type
      t.string :card_exp_month
      t.string :card_exp_year

      t.timestamps null: false
    end

    add_index :charges, :stripe_id, unique: true
  end
end

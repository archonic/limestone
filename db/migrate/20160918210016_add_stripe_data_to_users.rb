class AddStripeDataToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :stripe_id, :string
    add_column :users, :stripe_subscription_id, :string
    add_column :users, :card_last4, :string
    add_column :users, :card_exp_month, :integer
    add_column :users, :card_exp_year, :integer
    add_column :users, :card_type, :string
  end
end

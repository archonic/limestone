# frozen_string_literal: true

class AddPayToUsers < ActiveRecord::Migration[6.0]
  def change
    # Remove old payment columns on User
    remove_column :users, :stripe_id
    remove_column :users, :stripe_subscription_id
    remove_column :users, :trialing
    remove_column :users, :past_due
    remove_column :users, :current_period_end

    # Install Pay columns on billable (User)
    change_table :users do |t|
      t.string :processor
      t.string :processor_id
      t.datetime :trial_ends_at
      # Already have these fields
      # t.string :card_type
      # t.string :card_last4
      # t.string :card_exp_month
      # t.string :card_exp_year
      t.text :extra_billing_info
    end
  end
end

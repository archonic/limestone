# frozen_string_literal: true

class AddOwnerTypeToPay < ActiveRecord::Migration[6.0]
  def change
    # add_column :pay_charges, :owner_type, :string
    add_column :pay_subscriptions, :owner_type, :string

    # Backfill owner_type column to match your Billable model
    Pay::Charge.update_all owner_type: "User"
    Pay::Subscription.update_all owner_type: "User"
  end
end

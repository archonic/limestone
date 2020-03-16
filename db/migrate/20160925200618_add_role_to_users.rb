# frozen_string_literal: true

class AddRoleToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :role, :integer
    add_column :users, :trialing, :boolean, null: false, default: true
    add_column :users, :past_due, :boolean, null: false, default: false
  end
end

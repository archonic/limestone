# frozen_string_literal: true

class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.integer :amount, null: false
      t.string :associated_role, null: false
      t.string :stripe_id
    end
  end
end

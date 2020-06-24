# frozen_string_literal: true

class AddActiveToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :active, :boolean, default: true, null: false
  end
end

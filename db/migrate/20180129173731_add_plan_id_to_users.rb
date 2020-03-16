# frozen_string_literal: true

class AddPlanIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :plan_id, :integer
  end
end

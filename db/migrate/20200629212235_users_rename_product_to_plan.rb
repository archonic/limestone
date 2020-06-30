# frozen_string_literal: true

class UsersRenameProductToPlan < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :product_id, :plan_id
  end
end

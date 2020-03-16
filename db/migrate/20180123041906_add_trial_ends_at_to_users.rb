# frozen_string_literal: true

class AddTrialEndsAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :current_period_end, :datetime
    add_index :users, :current_period_end
  end
end

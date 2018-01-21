class AddDiscardToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :discarded_at, :datetime
  end
end

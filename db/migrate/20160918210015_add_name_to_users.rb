class AddNameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :first_name, :string, after: :email
    add_column :users, :last_name, :string, after: :first_name
    add_column :users, :full_name, :string, after: :last_name
  end
end

class ChangeUsersFullNameToName < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :full_name, :name
  end
end

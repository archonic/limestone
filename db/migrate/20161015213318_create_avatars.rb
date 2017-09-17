class CreateAvatars < ActiveRecord::Migration[5.0]
  def change
    create_table :avatars do |t|
      byebug
      t.text :image_data
      t.references :users, null: false, index: true
      t.timestamps
    end
  end
end

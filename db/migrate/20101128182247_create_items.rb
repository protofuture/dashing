class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :private_path
      t.integer :user_id
      t.boolean :shared

      t.timestamps
    end
    add_index :items, :user_id
  end

  def self.down
    drop_table :items
  end
end

class AddSharePathToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :share_path, :string
  end

  def self.down
    remove_column :users, :share_path
  end
end

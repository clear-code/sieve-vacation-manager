class UsersEmailUniqueIndex < ActiveRecord::Migration
  def change
    add_index :users, [:id, :email], :unique => true
  end
end

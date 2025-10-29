class ChangeUsernameInUsers < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :username, :string, default: "", null: false
  end
end

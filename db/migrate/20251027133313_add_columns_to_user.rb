class AddColumnsToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :username, :string
    add_column :users, :balance, :decimal
    add_column :users, :decision_score, :decimal
    add_column :users, :avatar, :string
  end
end

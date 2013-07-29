class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_type, :string
    add_column :users, :agent_id, :integer

    add_index :users, :agent_id
  end
end

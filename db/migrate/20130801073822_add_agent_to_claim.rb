class AddAgentToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :agent_id, :integer
    add_index :claims, :agent_id
  end
end

class AddAgentIdToQuote < ActiveRecord::Migration
  def change
    add_column :quotes, :agent_id, :integer
    add_index :quotes, :agent_id
  end
end

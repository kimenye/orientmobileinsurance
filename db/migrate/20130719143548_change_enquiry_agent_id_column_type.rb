class ChangeEnquiryAgentIdColumnType < ActiveRecord::Migration
  def change
    remove_column :enquiries, :agent_id
    add_column :enquiries, :agent_id, :integer
  end
end

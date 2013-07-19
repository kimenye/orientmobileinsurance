class ChangeEnquiryAgentIdColumnType < ActiveRecord::Migration
  def change
    change_column :enquiries, :agent_id, :integer
  end
end

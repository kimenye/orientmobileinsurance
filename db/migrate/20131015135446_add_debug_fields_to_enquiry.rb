class AddDebugFieldsToEnquiry < ActiveRecord::Migration
  def change
    add_column :enquiries, :user_agent, :string
  end
end

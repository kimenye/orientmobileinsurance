class AddUserAgentToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :user_agent, :string
  end
end

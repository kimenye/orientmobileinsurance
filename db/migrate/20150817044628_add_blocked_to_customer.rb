class AddBlockedToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :blocked, :boolean, default: false
  end
end

class AddIsAdminToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :is_admin, :boolean, :default => false
  end
end

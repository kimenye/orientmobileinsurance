class AddActiveToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :active, :boolean, :default => true
    add_column :devices, :version, :integer, :default => 0
  end
end

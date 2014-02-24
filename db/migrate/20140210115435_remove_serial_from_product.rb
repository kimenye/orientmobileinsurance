class RemoveSerialFromProduct < ActiveRecord::Migration
  def up
    remove_column :products, :serial
  end
end

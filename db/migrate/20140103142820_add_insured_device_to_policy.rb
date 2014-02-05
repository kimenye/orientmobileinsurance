class AddInsuredDeviceToPolicy < ActiveRecord::Migration
  def change
    add_column :policies, :insured_device_id, :integer
    add_index :policies, :insured_device_id
  end
end

class AddFlagForDamagedEforeCutOffToInsuredDevices < ActiveRecord::Migration
  def change
    add_column :insured_devices, :damaged_flag, :boolean
    add_column :insured_devices, :damage_reported, :datetime
  end
end

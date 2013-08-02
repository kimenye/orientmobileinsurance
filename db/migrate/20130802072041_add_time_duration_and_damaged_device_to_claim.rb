class AddTimeDurationAndDamagedDeviceToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :time_duration, :datetime
    add_column :claims, :damaged_device, :boolean
  end
end

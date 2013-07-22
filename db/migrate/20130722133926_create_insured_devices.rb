class CreateInsuredDevices < ActiveRecord::Migration
  def change
    create_table :insured_devices do |t|
      t.references :customer
      t.references :device
      t.string :imei

      t.timestamps
    end
    add_index :insured_devices, :customer_id
    add_index :insured_devices, :device_id
  end
end

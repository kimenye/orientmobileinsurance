class AddValuesToInsuredDevice < ActiveRecord::Migration
  def change
    add_column :insured_devices, :insurance_value, :decimal
    add_column :insured_devices, :replacement_value, :decimal
    add_column :insured_devices, :premium_value, :decimal
  end
end

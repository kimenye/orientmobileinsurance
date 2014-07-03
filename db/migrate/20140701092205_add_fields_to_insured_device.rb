class AddFieldsToInsuredDevice < ActiveRecord::Migration
  def change
    add_column :insured_devices, :prepaid, :boolean
    add_column :insured_devices, :activated, :boolean
  end
end

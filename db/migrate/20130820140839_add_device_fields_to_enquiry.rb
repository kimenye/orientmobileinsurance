class AddDeviceFieldsToEnquiry < ActiveRecord::Migration
  def change
    add_column :enquiries, :model, :string
    add_column :enquiries, :vendor, :string
    add_column :enquiries, :marketing_name, :string
    add_column :enquiries, :detected, :boolean
  end
end

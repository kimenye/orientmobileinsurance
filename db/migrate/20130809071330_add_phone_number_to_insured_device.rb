class AddPhoneNumberToInsuredDevice < ActiveRecord::Migration
  def change
    add_column :insured_devices, :phone_number, :string
  end
end

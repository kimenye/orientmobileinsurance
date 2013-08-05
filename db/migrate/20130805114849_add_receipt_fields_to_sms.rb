class AddReceiptFieldsToSms < ActiveRecord::Migration
  def change
    add_column :sms, :delivered, :boolean
  end
end

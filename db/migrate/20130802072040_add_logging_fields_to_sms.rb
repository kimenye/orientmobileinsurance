class AddLoggingFieldsToSms < ActiveRecord::Migration
  def change
    add_column :sms, :request, :text
    add_column :sms, :response, :text
    add_column :sms, :receipt_id, :string
  end
end

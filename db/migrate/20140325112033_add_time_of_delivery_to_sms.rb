class AddTimeOfDeliveryToSms < ActiveRecord::Migration
  def change
    add_column :sms, :time_of_delivery, :timestamp
  end
end

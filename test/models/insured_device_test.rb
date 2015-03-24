# == Schema Information
#
# Table name: insured_devices
#
#  id                :integer          not null, primary key
#  customer_id       :integer
#  device_id         :integer
#  imei              :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  yop               :integer
#  phone_number      :string(255)
#  damaged_flag      :boolean
#  damage_reported   :datetime
#  insurance_value   :decimal(, )
#  replacement_value :decimal(, )
#  premium_value     :decimal(, )
#  quote_id          :integer
#

require "test_helper"

class InsuredDeviceTest < ActiveSupport::TestCase

  test "Should strip out any whitespace from insured device phone numbers" do
  	new_device = InsuredDevice.new(phone_number: " +254 722123456 ")
  	new_device.save!

  	new_device = InsuredDevice.find(new_device.id)
  	assert_equal "+254722123456", new_device.phone_number
  end

  test "Should prepend insured device phone numbers with a +" do
  	new_device = InsuredDevice.new(phone_number: " 254 722123456 ")
  	new_device.save!

  	new_device = InsuredDevice.find(new_device.id)
  	assert_equal "+254722123456", new_device.phone_number
  end
end

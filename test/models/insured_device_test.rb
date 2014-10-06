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
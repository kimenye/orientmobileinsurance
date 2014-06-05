require "test_helper"
class DeviceNameTest < ActionDispatch::IntegrationTest

  test "We can use the model and vendor name to get the device in the catalogue (Iphone)" do
    dev = Device.create! :vendor => "Apple", :model => "IPHONE 5 - 16GB", :marketing_name => "IPHONE 5 - 16GB", :catalog_price => 150.00
    device = Device.model_search("Apple", "IPHONE 5 - 16GB").first
    assert !device.nil?
    assert_equal device.model, dev.model
    assert_equal device.marketing_name, dev.marketing_name
    assert_equal device.vendor, dev.vendor
  end
end
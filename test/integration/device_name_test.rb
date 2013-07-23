require "test_helper"
class DeviceNameTest < ActionDispatch::IntegrationTest

  test "We can use the model name to get the device in the catalogue (Iphone)" do
    dev = Device.create! :vendor => "Apple", :model => "IPHONE 5 - 16GB", :marketing_name => "IPHONE 5 - 16GB", :wholesale_price => 100.00, :catalog_price => 150.00
    device = Device.device_similar_to(Device.get_marketing_search_parameter("Apple"), Device.get_marketing_search_parameter("iPhone"), Device.get_marketing_search_parameter("iPhone")).first
    assert !device.nil?
    assert_equal device.model, dev.model
    assert_equal device.marketing_name, dev.marketing_name
    assert_equal device.vendor, dev.vendor
  end

  test "We can use the model name to get the device in the catalogue (Samsung)" do
    dev = Device.create! :vendor => "Samsung", :model => "GALAXY I9300-S3-64GB", :marketing_name => "SAMSUNG GALAXY I9300-S3-64GB", :wholesale_price => 100.00, :catalog_price => 150.00
    device = Device.device_similar_to("Samsung", "GT-I9300", Device.get_marketing_search_parameter("Galaxy S3")).first
    assert !device.nil?
    assert_equal device.model, dev.model
    assert_equal device.marketing_name, dev.marketing_name
    assert_equal device.vendor, dev.vendor
  end

  test "The get_marketing_search_parameter replaces whitespaces with % signs" do
    d = Device.new
    v = Device.get_marketing_search_parameter "Galaxy S3"
    assert_equal v, "%Galaxy%S3%"
  end
end
require "test_helper"
class DeviceNameTest < ActionDispatch::IntegrationTest

  test "We can use the model name to get the device in the catalogue (Iphone)" do
    #Device.find_or_create_by_model_and
    dev = Device.create! :vendor => "Apple", :model => "IPHONE 5 - 16GB", :marketing_name => "IPHONE 5 - 16GB", :wholesale_price => 100.00, :catalog_price => 150.00
    #device = Device.device_similar_to(dev.vendor, dev.model, dev.marketing_name).first
    device = Device.device_similar_to(dev.get_marketing_search_parameter("Apple"), dev.get_marketing_search_parameter("iPhone"), dev.get_marketing_search_parameter("iPhone")).first
    assert !device.nil?
  end

  test "We can use the model name to get the device in the catalogue (Samsung)" do
    #Device.find_or_create_by_model_and
    dev = Device.create! :vendor => "Samsung", :model => "GALAXY I9300-S3-64GB", :marketing_name => "SAMSUNG GALAXY I9300-S3-64GB", :wholesale_price => 100.00, :catalog_price => 150.00
    #device = Device.device_similar_to(dev.vendor, dev.model, dev.marketing_name).first
    device = Device.device_similar_to(dev.get_marketing_search_parameter("Samsung"), dev.get_marketing_search_parameter("GT-I9300"), dev.get_marketing_search_parameter("Galaxy S3")).first
    assert !device.nil?
  end

  test "" do
    d = Device.new
    v = d.get_marketing_search_parameter "Galaxy S3"
    assert_equal v, "%Galaxy%S3%"
  end
end
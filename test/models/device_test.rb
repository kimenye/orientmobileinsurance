require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  
  test "When calling insurance value by year it calculates the correct month range" do
    # assert true
    device = devices(:simple)

    assert_equal device.catalog_price, device.get_insurance_value(nil, Time.now.year)
    assert_equal (device.catalog_price * 0.5), device.get_insurance_value(nil, Time.now.year-1)
  end

end

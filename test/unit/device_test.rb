require 'test_helper'


class DeviceTest < ActiveSupport::TestCase

  before do
    @device = Device.new ({
      :vendor => "Test",
      :model => "iPhone",
      :marketing_name => "iPhone",
      :fd_insured_value => 10.0,
      :yop_insured_value => 7.0,
      :prev_insured_value => 5.0
    })
  end

  test "For a code starting with FX the fd_insured_value is used for the insurance value" do
    v = @device.get_insurance_value "FXP0001", Time.now.year
    assert_equal 10.0, v
  end

  test "For a code starting with FX the if the year of purchase is not the current year then the insurance value is that of the previous year" do
    v = @device.get_insurance_value "FXP001", Time.now.year - 1
    assert_equal 5.0, v
  end

  test "For a code starting not starting with FX the yop_insured_value is used for the insurance value if the year of purchase is the same as the current year" do
    v = @device.get_insurance_value nil, Time.now.year
    assert_equal 7.0, v
    end

  test "For a code starting not starting with FX the prev_insured_value is used for the insurance value if the year of purchase is before the current year" do
    v = @device.get_insurance_value nil, Time.now.year - 1
    assert_equal 5.0, v
  end

end
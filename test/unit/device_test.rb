require 'test_helper'


class DeviceTest < ActiveSupport::TestCase

  before do
    @device = Device.new ({
      :vendor => "Test",
      :model => "iPhone",
      :marketing_name => "iPhone",
      :catalog_price => 10.0
      # :fd_insured_value => 10.0,
      # :yop_insured_value => 7.0,
      # :stl_insured_value => 10.0,
      # :prev_insured_value => 5.0
    })
    
    @month_yrs = Device.month_ranges
  end

  test "For a code starting with FX purchased within the last calendar year, the insurace value equals the catalog price" do
    month = @month_yrs[12].split(" ")[0]
    year = @month_yrs[12].split(" ")[1]
    v = @device.get_insurance_value_by_month_and_year "FXP0001", month, year
    assert_equal @device.catalog_price, v
  end

  test "For a code starting with STL purchased within the last calendar year, the insurace value equals the catalog price" do
    month = @month_yrs[12].split(" ")[0]
    year = @month_yrs[12].split(" ")[1]
    v = @device.get_insurance_value_by_month_and_year "STL0001", month, year
    assert_equal @device.catalog_price, v
  end

  # test "For a code starting with FX purchased in the first period the insurace value equals the catalog price" do
  #   month = @month_yrs[5].split(" ")[0]
  #   year = @month_yrs[5].split(" ")[1]
  #   v = @device.get_insurance_value_by_month_and_year "FXP0001", month, year
  #   assert_equal @device.catalog_price, v
  # end

  test "For a code starting with FX purchased in the fourth period the insurace value equals 75% of the catalog price" do
    month = @month_yrs[14].split(" ")[0]
    year = @month_yrs[14].split(" ")[1]
    v = @device.get_insurance_value_by_month_and_year "FXP0001", month, year
    assert_equal 0.75 * @device.catalog_price, v
  end

  test "For a code starting with FX purchased in the fifth period the insurace value equals 50% of the catalog price" do
    month = @month_yrs[17].split(" ")[0]
    year = @month_yrs[17].split(" ")[1]
    v = @device.get_insurance_value_by_month_and_year "FXP0001", month, year
    assert_equal 0.5 * @device.catalog_price, v
  end

  test "For a code starting with FX purchased in the sixth period the insurace value equals 25% of the catalog price" do
    month = @month_yrs[20].split(" ")[0]
    year = @month_yrs[20].split(" ")[1]
    v = @device.get_insurance_value_by_month_and_year "FXP0001", month, year
    assert_equal 0.25 * @device.catalog_price, v
  end

  test "For a code not starting with FX purchased in the second period the insurace value equals 95% of the catalog price" do
    month = @month_yrs[7].split(" ")[0]
    year = @month_yrs[7].split(" ")[1]
    v = @device.get_insurance_value_by_month_and_year "BLAH0001", month, year
    assert_equal 0.95 * @device.catalog_price, v
  end

  test "For a code not starting with FX purchased in the third period the insurace value equals 87.5% of the catalog price" do
    month = @month_yrs[11].split(" ")[0]
    year = @month_yrs[11].split(" ")[1]
    v = @device.get_insurance_value_by_month_and_year "BLAH0001", month, year
    assert_equal 0.875 * @device.catalog_price, v
  end

  test "For a code not starting with FX purchased in the fourth period the insurace value equals 75% of the catalog price" do
    month = @month_yrs[14].split(" ")[0]
    year = @month_yrs[14].split(" ")[1]
    v = @device.get_insurance_value_by_month_and_year "BLAH0001", month, year
    assert_equal 0.75 * @device.catalog_price, v
  end

  test "For a code not starting with FX purchased in the fifth period the insurace value equals 50% of the catalog price" do
    month = @month_yrs[17].split(" ")[0]
    year = @month_yrs[17].split(" ")[1]
    v = @device.get_insurance_value_by_month_and_year "BLAH0001", month, year
    assert_equal 0.5 * @device.catalog_price, v
  end

  test "For a code not starting with FX purchased in the sixth period the insurace value equals 25% of the catalog price" do
    month = @month_yrs[20].split(" ")[0]
    year = @month_yrs[20].split(" ")[1]
    v = @device.get_insurance_value_by_month_and_year "BLAH0001", month, year
    assert_equal 0.25 * @device.catalog_price, v
  end


  # test "For a code starting with FX the fd_insured_value is used for the insurance value" do
  #   v = @device.get_insurance_value "FXP0001", Time.now.year
  #   assert_equal 10.0, v
  # end

  # test "For a code starting with STL the stl_insured_value is used for the insurance value" do
  #   v = @device.get_insurance_value "STL000", Time.now.year
  #   assert_equal 10.0, v
  # end

  # test "For a code starting with FX or STL the if the year of purchase is not the current year then the insurance value is that of the previous year" do
  #   v = @device.get_insurance_value "FXP001", Time.now.year - 1
  #   assert_equal 5.0, v

  #   v = @device.get_insurance_value "STL000", Time.now.year - 1
  #   assert_equal 5.0, v
  # end

  # test "For a code starting not starting with FX the yop_insured_value is used for the insurance value if the year of purchase is the same as the current year" do
  #   v = @device.get_insurance_value nil, Time.now.year
  #   assert_equal 7.0, v
  #   end

  # test "For a code starting not starting with FX the prev_insured_value is used for the insurance value if the year of purchase is before the current year" do
  #   v = @device.get_insurance_value nil, Time.now.year - 1
  #   assert_equal 5.0, v
  # end

  test "Should only return devices that are active" do
    Device.delete_all

    inactive = Device.create! :model => "iPhone", :vendor => "Apple", :marketing_name => "iPhone", :catalog_price => 5, :active => false
    result = Device.device_similar_to("Apple", "iPhone", Device.get_marketing_search_parameter("iPhone")).first

    assert_equal result, nil
    result = Device.wider_search("iPhone").first
    assert_equal result, nil


    inactive.active = true
    inactive.save!
    result = Device.device_similar_to("Apple", "iPhone", Device.get_marketing_search_parameter("iPhone")).first
    assert_equal result.id, inactive.id

    result = Device.wider_search("iPhone").first
    assert_equal result.id, inactive.id
  end

  test "A device is STL serviceable only if the phone make is either Forme, Tecno, iTel or G-Tide" do
    Device.delete_all
    device = Device.create! :vendor => "Tecno", :model => "N7", :marketing_name => "N7", :catalog_price => 5
    assert_equal true, device.is_stl

    device = Device.create! :model => "iPhoneTel", :vendor => "Apple", :marketing_name => "iPhone", :catalog_price => 5, :active => false
    assert_equal false, device.is_stl

    device = Device.create! :vendor => "Forme", :model => "N7", :marketing_name => "N7", :catalog_price => 5
    assert_equal true, device.is_stl

    device = Device.create! :vendor => "iTel", :model => "N7", :marketing_name => "N7", :catalog_price => 5
    assert_equal true, device.is_stl

    device = Device.create! :vendor => "G-Tide", :model => "N7", :marketing_name => "N7", :catalog_price => 5
    assert_equal true, device.is_stl
  end

  test "A device is serviceable by STL if it is stocked by both" do
    Device.delete_all
    device = Device.create! :vendor => "RIM", :dealer_code => "Both", :model => "9300 3G", :catalog_price => 5, :marketing_name => "abc"

    assert_equal true, device.is_servicable_at_both
  end

  test "A device is serviceable by STL and FD if it is stocked by both" do
    Device.delete_all
    device = Device.create! :vendor => "RIM", :dealer_code => "Both", :model => "9300 3G", :catalog_price => 5, :marketing_name => "abc"

    assert_equal true, device.is_servicable_at_both
  end
end
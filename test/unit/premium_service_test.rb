require 'test_helper'

class PremiumServiceTest < ActiveSupport::TestCase

  test "Should insure phones purchased in the current year if no sales code is provided" do
    service = PremiumService.new
    insurable = service.is_insurable(Time.now.year, nil)
    assert true == insurable
    end

  test "Should insure phones purchased in the previous year if no sales code is provided" do
    service = PremiumService.new
    insurable = service.is_insurable(Time.now.year-1, nil)
    assert true == insurable
  end

  test "Should not insure phones purchased more than a year ago if no sales code is provided" do
    service = PremiumService.new
    insurable = service.is_insurable(Time.now.year-2, nil)
    assert false == insurable
  end

  test "Should insure phones if a valid sales code is provided" do
    service = PremiumService.new
    insurable = service.is_insurable(Time.now.year-2, "test")
    assert true == insurable, "Should insure any phones if sales code is given"
  end

  test "Insurance value should be 100% of catalogue price if sales code starts with FX" do
    service = PremiumService.new
    insurance_value = service.calculate_insurance_value(800, "FX001" , Time.now.year)
    assert insurance_value == 800, "Catalogue price should equal insurance value"
  end

  test "Insurance value should be 87.5% of catalogue price if sales code does not start with FX and year of purchase is same as current year" do
    service = PremiumService.new
    insurance_value = service.calculate_insurance_value(800, "JM001" , Time.now.year)
    assert insurance_value == (0.875 * 800), "Catalogue price should be 87.5%"
  end

  test "Insurance value should be 37.5% of catalogue price if sales code does not start with FX and year of purchase is less than current year" do
    service = PremiumService.new
    insurance_value = service.calculate_insurance_value(800, "JM001" , Time.now.year - 1)
    assert insurance_value == (0.375 * 800), "Catalogue price should be 37.5%"
  end
end
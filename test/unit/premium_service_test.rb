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
end
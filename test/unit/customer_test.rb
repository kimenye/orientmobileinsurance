require "test_helper"

class CustomerTest < ActiveSupport::TestCase

  before do
    @simple = Customer.new :name => "PRISCILLA NJERI KINIIYA"
  end

  test "The customer names can be split" do
    assert_equal @simple.first_name, "PRISCILLA"
    assert_equal @simple.last_name, "KINIIYA"
    assert_equal @simple.middle_name, "NJERI"

    @simple.name = "Mike"
    assert_equal @simple.first_name, "Mike"
    assert_equal @simple.last_name, nil
    assert_equal @simple.middle_name, nil

    @simple.name = "Mike Nganga"
    assert_equal @simple.first_name, "Mike"
    assert_equal @simple.last_name, "Nganga"
    assert_equal @simple.middle_name, nil
  end
end

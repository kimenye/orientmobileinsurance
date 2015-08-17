# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  id_passport            :string(255)
#  email                  :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  phone_number           :string(255)
#  alternate_phone_number :string(255)
#  lead                   :boolean          default(TRUE)
#  customer_type          :string(255)
#  company_name           :string(255)
#  blocked                :boolean          default(FALSE)
#

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

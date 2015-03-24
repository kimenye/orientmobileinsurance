# == Schema Information
#
# Table name: devices
#
#  id                         :integer          not null, primary key
#  vendor                     :string(255)
#  model                      :string(255)
#  marketing_name             :string(255)
#  catalog_price              :decimal(, )
#  wholesale_price            :decimal(, )
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  fd_insured_value           :decimal(, )
#  fd_replacement_value       :decimal(, )
#  fd_koil_invoice_value      :decimal(, )
#  yop_insured_value          :decimal(, )
#  yop_replacement_value      :decimal(, )
#  yop_fd_koil_invoice_value  :decimal(, )
#  prev_insured_value         :decimal(, )
#  prev_replacement_value     :decimal(, )
#  prev_fd_koil_invoice_value :decimal(, )
#  device_type                :string(255)
#  stock_code                 :string(255)
#  active                     :boolean          default(TRUE)
#  version                    :integer          default(0)
#  stl_insured_value          :decimal(, )
#  stl_replacement_value      :decimal(, )
#  stl_koil_invoice_value     :decimal(, )
#  dealer_code                :string(255)
#  user_agent                 :string(255)
#

require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  
  test "When calling insurance value by year it calculates the correct month range" do
    # assert true
    device = devices(:simple)

    assert_equal device.catalog_price, device.get_insurance_value(nil, Time.now.year)
    assert_equal (device.catalog_price * 0.5), device.get_insurance_value(nil, Time.now.year-1)
  end

end

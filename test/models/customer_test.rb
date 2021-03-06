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

  test "A customer is a lead if the customer has received a quote but hasn't made a payment" do

    customer = Customer.create! :name => "Test", :id_passport => "1234567890", :email => "1234567890@gmail.com", :phone_number => "254705866564"
    assert_equal true, customer.is_a_lead?
    assert_equal false, customer.has_policy?

    insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => nil, :imei => "123456789012345", :yop => 2013
    quote = Quote.create! :insured_device_id => insured_device.id, :insured_value => 1000, :premium_type => "Annual", :annual_premium => 300, :monthly_premium => 200, :account_name => "OMIXRY9832", :expiry_date => 3.days.from_now, :agent_id => nil
    policy = Policy.create! :policy_number => "AAA/000", :quote_id => quote.id, :status => "Active", :start_date => Time.now, :expiry => 1.year.from_now, :insured_device_id => insured_device.id
    payment = Payment.create! :method => "JP", :policy_id => policy.id, :amount => 300, :reference => "ABC"

    customer = Customer.find(customer.id)
    assert_equal true, customer.has_policy?
    assert_equal false, customer.is_a_lead?
  end

  test "A customer who made multiple enquiries with different phones will display at least two phone numbers" do
    customer = Customer.create! :name => "Test", :id_passport => "1234567890", :email => "1234567890@gmail.com", :phone_number => "254705866564"

    InsuredDevice.create! :customer_id => customer.id, :device_id => nil, :imei => "123456789012345", :yop => 2013, :phone_number => "254733866564"
    InsuredDevice.create! :customer_id => customer.id, :device_id => nil, :imei => "123456789012345", :yop => 2013, :phone_number => "254705866564"

    customer = Customer.find(customer.id)
    assert customer.phone_number, "254705866564"
    assert customer.alternate_number, "254733866564"
  end
end

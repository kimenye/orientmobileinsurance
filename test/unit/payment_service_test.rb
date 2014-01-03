require 'test_helper'

class PaymentServiceTest < ActiveSupport::TestCase

	before do
		Payment.delete_all
	    Claim.delete_all
	    Policy.delete_all
	    Quote.delete_all
	    InsuredDevice.delete_all
	    Customer.delete_all
	    Enquiry.delete_all
	    Message.delete_all
	    Sms.delete_all
	    Device.delete_all
	    Device.create! :vendor => "Tecno", :model => "N7", :marketing_name => "Tecno N7", :catalog_price => 200
	end

	test "It can handle the payment of a single device quote" do			
	    customer = Customer.create! :name => "Test Customer", :id_passport => "1234567890", :phone_number => "254705866564", :email => "kimenye@gmail.com", :customer_type => "Invidual"
	    insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => Device.first.id, :imei => "123456789012345", :yop => 2013, :phone_number => "254705866564"
	    quote = Quote.create! :insured_device_id => insured_device.id, :insured_value => 1000, :premium_type => "Annual", :annual_premium => 300, :monthly_premium => 200, :account_name => "OMIXRY9832", :expiry_date => 3.days.from_now

	    service = PaymentService.new()

	    assert_equal true, service.is_pending_payment?(quote.account_name)
	    service.handle_payment(quote.account_name, quote.annual_premium, "ABCDEFGH", "MPESA")
	    assert_equal false, service.is_pending_payment?(quote.account_name)

	    policy = Policy.find_by_quote_id(quote.id)
	    assert_equal false, policy.nil?
	    assert_equal false, policy.is_owing?
	end

	test "Payment of a multiple device quote is only completed when the entire amount is paid up" do
		customer = Customer.create! :name => "Test Customer", :id_passport => "1234567890", :phone_number => "254705866564", :email => "kimenye@gmail.com", :customer_type => "Corporate"
		quote = Quote.create! :insured_value => 1000, :premium_type => "Annual", :annual_premium => 3000, :monthly_premium => 0, :account_name => "OMIXRY9832", :quote_type => "Corporate", :expiry_date => 3.days.from_now, :customer_id => customer.id
		insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => Device.first.id, :imei => "123456789012345", :yop => 2013, :phone_number => "254705866564", :quote_id => quote.id
		insured_device2 = InsuredDevice.create! :customer_id => customer.id, :device_id => Device.first.id, :imei => "123456789012347", :yop => 2013, :phone_number => "254705866565", :quote_id => quote.id

		service = PaymentService.new()
		assert_equal true, service.is_pending_payment?(quote.account_name)
		service.handle_payment(quote.account_name, 2000, "ABCDEFGH", "MPESA")
		assert_equal true, service.is_pending_payment?(quote.account_name)
		assert_equal 1, Payment.count
		assert_equal 1, Sms.count

		policies = Policy.find_all_by_quote_id(quote.id)
		assert_equal true, policies.empty?		

		service.handle_payment(quote.account_name, 1000, "ABCDEFGI", "MPESA")		
		assert_equal false, service.is_pending_payment?(quote.account_name)

		policies = Policy.find_all_by_quote_id(quote.id)
		assert_equal 2, policies.length		

	end
end

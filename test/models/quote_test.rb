# == Schema Information
#
# Table name: quotes
#
#  id                :integer          not null, primary key
#  insured_device_id :integer
#  annual_premium    :decimal(, )
#  monthly_premium   :decimal(, )
#  account_name      :string(255)
#  premium_type      :string(255)
#  expiry_date       :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  insured_value     :decimal(, )
#  agent_id          :integer
#  quote_type        :string(255)
#  customer_id       :integer
#  enquiry_id        :integer
#

require "test_helper"

class QuoteTest < ActiveSupport::TestCase

	test "A quote is corporate if the type is corporate" do
		q = Quote.new()
		q.quote_type = "Corporate"
		assert_equal true, q.is_corporate?
	end

	test 'Name is the account name' do
		q = Quote.new({ account_name: '1234567890' })
		assert_equal '1234567890', q.name
	end

	test 'An airtel quote has an enquiry of that type' do
		q = quotes(:airtel_iphone)
		assert q.is_airtel?
		assert_equal agents(:airtel).code, q.agent_code
	end

	test 'A quote expires if its past the expiry date' do
		q = Quote.new({ expiry_date: 3.days.ago })
		assert q.is_expired?
	end

	test 'A quote can tell its payment information' do
		quote = quotes(:airtel_iphone)
		assert !quote.is_installment?

		assert_equal 'Annual', quote.payment_option
		quote.premium_type = 'Monthly'

		assert_equal	'Installment', quote.payment_option
	end

	test "A quote has a direct customer if the quote type is corporate" do
		customer = Customer.create! :name => "Test", :id_passport => "1234567890", :email => "1234567890@gmail.com", :phone_number => "254705866564"
		q = Quote.new({ :customer_id => customer.id, :quote_type => "Corportate "})
		assert_equal customer.id, q.customer.id		
	end
end

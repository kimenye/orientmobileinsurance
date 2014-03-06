require "test_helper"

class QuoteTest < ActiveSupport::TestCase

	test "A quote is corporate if the type is corporate" do
		q = Quote.new()
		q.quote_type = "Corporate"
		assert_equal true, q.is_corporate?
	end

	test "A quote has a direct customer if the quote type is corporate" do
		customer = Customer.create! :name => "Test", :id_passport => "1234567890", :email => "1234567890@gmail.com", :phone_number => "254705866564"
		q = Quote.new({ :customer_id => customer.id, :quote_type => "Corportate "})
		assert_equal customer.id, q.customer.id		
	end
end
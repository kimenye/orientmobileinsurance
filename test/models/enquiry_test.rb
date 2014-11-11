require "test_helper"

class EnquiryTest < ActiveSupport::TestCase

	test "Should strip out any whitespace from insured device phone numbers" do
	  	enquiry = Enquiry.new(phone_number: " +254 722123456 ", source: "SMS")
	  	enquiry.save!

	  	enquiry = Enquiry.find(enquiry.id)
	  	assert_equal "+254722123456", enquiry.phone_number
	end

	# test "Should prepend insured device phone numbers with a +" do
	#   	enquiry = Enquiry.new(phone_number: " 254 722123456 ", source: "SMS")
	#   	enquiry.save!

	#   	enquiry = Enquiry.find(enquiry.id)
	#   	assert_equal "+254722123456", enquiry.phone_number
	# end
end
# == Schema Information
#
# Table name: enquiries
#
#  id                   :integer          not null, primary key
#  phone_number         :string(255)
#  text                 :string(255)
#  date_of_enquiry      :string(255)
#  source               :string(255)
#  sales_agent_code     :string(255)
#  url                  :string(255)
#  hashed_phone_number  :string(255)
#  detected_device_id   :string(255)
#  undetected_device_id :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  year_of_purchase     :integer
#  agent_id             :integer
#  hashed_timestamp     :string(255)
#  model                :string(255)
#  vendor               :string(255)
#  marketing_name       :string(255)
#  detected             :boolean
#  user_agent           :string(255)
#  id_type              :string(255)
#  customer_id          :string(255)
#  month_of_purchase    :string(255)
#  enquiry_type         :string(255)      default("omb")
#

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

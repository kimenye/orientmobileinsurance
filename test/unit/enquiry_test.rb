require 'test_helper'
class EnquiryTest < ActiveSupport::TestCase

  before do
    @enquiry = Enquiry.create!(:source => "DIRECT", :year_of_purchase => 2013, :customer_id => "1234567890")
  end

  test "A valid phone number will start with 2547..." do
    @enquiry.phone_number = "+254705866564"
    valid = @enquiry.save
    assert_equal true, valid

    @enquiry.phone_number = "+2547058665"
    valid = @enquiry.save
    assert_equal false, valid
  end
end

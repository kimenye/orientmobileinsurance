require "test_helper"

class EnquiryValidationFlowsTest < ActionDispatch::IntegrationTest

  test "A phone number and SMS are required for an enquiry" do
    assert_raises (ActiveRecord::RecordInvalid) {
       Enquiry.create! :phone_number => nil, :source => nil
    }
  end

  test "A year of purchase is not required for a new enquiry" do
    e = Enquiry.create! :phone_number => "254705866564", :source => "SMS"
    assert e.errors.empty?
  end

  test "A year of purchase is required when updating an enquiry" do
    e = Enquiry.create! :phone_number => "254705866564", :source => "SMS"
    assert_raises (ActiveRecord::RecordInvalid) {
      e.save!
    }
  end

  test "A year of purchase must be a number" do
    e = Enquiry.create! :phone_number => "254705866564", :source => "SMS"
    assert_raises (ActiveRecord::RecordInvalid) {
      e.year_of_purchase = "abcd"
      e.save!
    }
  end

  test "A year of purchase must be either this year or in the past" do
    e = Enquiry.create! :phone_number => "254705866564", :source => "SMS"
    assert_raises (ActiveRecord::RecordInvalid) {
      e.year_of_purchase = Time.now.year + 1
      e.save!
    }

    e.year_of_purchase = Time.now.year
    e.save!
    assert e.errors.empty?
  end
end

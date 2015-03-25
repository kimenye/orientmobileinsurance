require 'test_helper'

class EnquiryControllerTest < ActionController::TestCase
  
  test 'Airtel enquires should have the correct enquiry type' do
    post :airtel 
    assert_redirected_to enquiry_index_path

    enquiry = Enquiry.last
    assert_equal 'USSD', enquiry.source
    assert_equal 'Airtel', enquiry.enquiry_type
    assert_equal true, enquiry.is_airtel?

    # should also have the agent code set up
    assert_not_nil enquiry.agent
    assert enquiry.agent.is_airtel?
  end

end
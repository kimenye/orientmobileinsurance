require 'test_helper'

class EnquiryControllerTest < ActionController::TestCase
  
  test 'Airtel enquires should have the correct enquiry type' do
    post :airtel 
    assert_redirected_to enquiry_index_path
  end

end
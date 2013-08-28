require "test_helper"

class MessagesControllerTest < ActionController::TestCase

  test 'get index' do
    get :index
    assert_response :success
  end

  test 'create a message from a notification with no valid params' do
    post :create
    assert_response 422
  end

  test 'create a valid enquiry message' do
    post :create, { "MobileNumber" => "254705876765", "Text" => "Mobile" }
    assert_response :success
  end
end

require "test_helper"

class PagesControllerTest < ActionController::TestCase
  test "should get privacy_policy" do
    get :privacy_policy
    assert_response :success
  end

end

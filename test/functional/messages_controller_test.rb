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

  test "Mark message as delivered if receipt id matches the respose's reference" do
    Sms.delete_all

    service = SMSGateway.new
    xml = service.send "254722200200", "Hello World"

    assert_equal 1, Sms.count
    sms = Sms.first

    post :receipts, {"receipts"=> {"receipt"=> [{"msgid"=> "26567958","reference"=> "365d6a84","msisdn"=> "+254722200200","status"=> "D","timestamp"=> "20080831T15:59:24","billed"=> "NO"}]}}
    
    sms = Sms.first
    assert_equal true, sms.delivered
  end

  test "Save the message's delivery time" do
    Sms.delete_all

    service = SMSGateway.new
    xml = service.send "254722200200", "Hello World"

    assert_equal 1, Sms.count
    sms = Sms.first

    post :receipts, {"receipts"=> {"receipt"=> [{"msgid"=> "26567958","reference"=> "365d6a84","msisdn"=> "+254722200200","status"=> "D","timestamp"=> "20080831T15:59:24","billed"=> "NO"}]}}
    
    sms = Sms.first
    d = DateTime.parse('20080831T15:59:24')
    d = d.to_s.gsub("+00:00"," +0300").gsub("T", " ")
    
    assert_equal d, sms.time_of_delivery.to_s
  end
end

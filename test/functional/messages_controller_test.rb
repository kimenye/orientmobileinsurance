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
    post :create, { "MSISDN" => "254705876765", "Content" => "Mobile" }
    assert_response :success
  end

  test 'it handles messages with the keyword mobile' do
    Message.delete_all
    post :create, { "MSISDN" => "254705876765", "Content" => "Mobile" }
    assert_response :success

    assert_equal 1, Message.count
  end

  test "Can receive inbound MO" do
    post :create, { MSISDN: '254705866564', Shortcode: '70707', Content: 'Mobile', Channel: 'KENYA.SAFARICOM', DataType: '0', DateReceived: '1468230428', CampaignID: '128323' }
    assert_response :success
    assert_equal "success", response.body
  end

  test 'it forwards the message with keyword test to the development server' do
    Message.delete_all
    post :create, { "MSISDN" => "254705876765", "Content" => "test" }
    assert_response :success

    assert_equal 0, Message.count
  end

  test "Mark message as delivered if receipt id matches the respose's reference" do
    Sms.delete_all

    xml = SMSGateway.send "254722200200", "Hello World"

    assert_equal 1, Sms.count
    sms = Sms.first
    sms.receipt_id = "test"
    sms.save!

    post :receipts, { Reference: sms.receipt_id, Status: 'DELIVRD', DateDelivered: '1468236360' }
    assert_response :success
    # {"Reference"=>"12.2283.1468236299.3", "Status"=>"DELIVRD", "Datedelivered"=>"1468236360"}


    sms.reload
    assert_equal true, sms.delivered
  end

  test "Save the message's delivery time" do
    Sms.delete_all

    xml = SMSGateway.send "254722200200", "Hello World"

    assert_equal 1, Sms.count
    sms = Sms.first
    sms.receipt_id = "test2"
    sms.save!

    post :receipts, { Reference: sms.receipt_id, Status: 'DELIVRD', DateDelivered: '1468236360' }
    assert_response :success

    sms.reload
    assert_not_nil sms.time_of_delivery
  end
end

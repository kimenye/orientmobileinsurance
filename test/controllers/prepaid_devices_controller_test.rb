require "test_helper"

class PrepaidDevicesControllerTest < ActionController::TestCase
  # test "should get customer_details" do
  #   get :customer_details
  #   assert_response :success
  # end

  # test "should get confirmation" do
  #   get :confirmation
  #   assert_response :success
  # end

  test "Should create customer when they send in an imei and associate it with an isured device" do
  	Customer.delete_all
  	device = InsuredDevice.create! imei: "123456789012345", prepaid: true, activated: false
  	sms = SmsService.new
  	sms.handle_sms_sending(device.imei, "0722000000")

  	assert_equal "0722000000", Customer.first.phone_number
  	assert_equal device.id, Customer.first.insured_devices.first.id
  end

  test "Policy is activated once the user fills in their personal information" do
  	Customer.delete_all
  	customer = Customer.create! hashed_phone_number: "qwerty", name: "name", email: "email", phone_number: "12345", id_passport: "1234567"
  	quote = Quote.create! quote_type: "Corporate", customer_id: customer.id
  	device = InsuredDevice.create! imei: "123456789012345", prepaid: true, activated: false, customer_id: customer.id
  	policy = Policy.create! insured_device_id: device.id, status: "Pending"
  	post :confirmation, { customer: {phone_number: "qwerty", name: "Muaad", email: "email", id_passport: "12345"} }
  	
  	policy = Policy.first
  	device = InsuredDevice.first
  	customer = Customer.first
  	quote = Quote.first

  	assert_equal "Active", policy.status
  	assert_equal quote.id, policy.quote_id
  	assert_equal true, device.activated
  	assert_equal "Muaad", customer.name
  	assert_equal "email", customer.email
  	assert_equal "12345", customer.id_passport
  	assert_equal 365.days.from_now.year, policy.expiry.year
  	assert_equal 365.days.from_now.month, policy.expiry.month
  	assert_equal 365.days.from_now.day, policy.expiry.day
  
  	assert_equal Time.now.year, policy.start_date.year
  	assert_equal Time.now.month, policy.start_date.month
  	assert_equal Time.now.day, policy.start_date.day
  end
end

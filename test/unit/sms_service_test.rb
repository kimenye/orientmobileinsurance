require 'test_helper'

class SmsServiceTest < ActiveSupport::TestCase
  test 'Can handle a message that is not understood' do  
    message = SmsService.handle_sms_sending('googoogaggah', '254705123456')
    assert_equal 3, message.message_type
  end

  test 'Can handle a keyword message' do
    message = SmsService.handle_sms_sending('Mobile', '254705123456')
    assert_equal 1, message.message_type
  end

  test 'Can activate a pending policy' do
    message = SmsService.handle_sms_sending('123456789012345', '254705123456')
    assert_equal 2, message.message_type
  end

  test 'The default sms payment instructions' do
    message = SmsService.payment_instructions('OMB12345', Time.now)
    assert_equal "Please pay via MPesa (Business No. #{ENV['MPESA']}) or Airtel Money (Business Name #{ENV['AIRTEL']}). Your account no. OMB12345 is valid till #{Time.now.utc.to_s(:full)}.", message
  end

  test 'The default airtel payment instructions' do
    message = SmsService.payment_instructions('OMB12345', Time.now, 'Airtel')
    assert_equal "Please pay via Airtel Money (Business Name -). Your account no. OMB12345 is valid till #{Time.now.utc.to_s(:full)}.", message 
  end
end

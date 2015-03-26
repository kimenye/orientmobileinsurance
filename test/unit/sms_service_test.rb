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


end

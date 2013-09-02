require 'test_helper'

class SMSGatewayTest < ActiveSupport::TestCase

  test "If a text has more than 160 characters it should be split" do
    one_sixty_chars = (0..84).to_a.join
    service = SMSGateway.new
    
    response = service.should_split_message one_sixty_chars
    assert_equal false, response
    
    one_sity_one_chars = (0..90).to_a.join
    response = service.should_split_message one_sity_one_chars
    assert_equal true, response    
  end
  
  test "Should not split a text if it is less than 160 characters" do
    exp = ["1235"]
    service = SMSGateway.new
    
    result = service.split_message "1235"
    assert_equal exp, result
    
    one_sixty_chars = (0..84).to_a.join
    exp = [one_sixty_chars]
    result = service.split_message one_sixty_chars

    assert_equal exp, result
  end
  
  test "Should split texts if character is more than 160 characters" do
    seg_one = "I wish i was a little bit taller baller grom wiht fds fsdlf sdlfjlkdsjf adfhd fjd flkdsjfkdjs fdsfdkfjsk fhds fkdshf asfjdsfsAnd here is where the string start."
    seg_two = "the second component"
    
    arr = [seg_one,seg_two]
    msg = arr.join
    
    service = SMSGateway.new
    result = service.split_message msg
    assert_equal arr.length, result.length    
    assert_equal arr[0], result[0]
    assert_equal arr[1], result[1]
  end
  
  test "Should send two messages if the text is more than 160 characters" do
    seg_one = "I wish i was a little bit taller baller grom wiht fds fsdlf sdlfjlkdsjf adfhd fjd flkdsjfkdjs fdsfdkfjsk fhds fkdshf asfjdsfsAnd here is where the string start."
    seg_two = "the second component"
    
    arr = [seg_one,seg_two]
    msg = arr.join
    
    service = SMSGateway.new
    Sms.delete_all
    service.send "123", msg
    assert_equal 2, Sms.count
  end

  test "the gateway creates the correct xml" do

    valid_xml = "<?xml version=\"1.0\"?>
      <methodCall>
        <methodName>EAPIGateway.SendSMS</methodName>
        <params>
          <param>
            <value>
              <struct>
                <member>
                  <name>Numbers</name>
                  <value>254722200200</value>
                </member>
                <member>
                  <name>SMSText</name>
                  <value>Hello World</value>
                </member>
                <member>
                  <name>Password</name>
                  <value>#{ENV['SMS_GATEWAY_PASSWORD']}</value>
                </member>
                <member>
                  <name>Service</name>
                  <value>
                    <int>#{ENV['SMS_GATEWAY_SERVICE_ID']}</int>
                  </value>
                </member>
                <member>
                  <name>Receipt</name>
                  <value>Y</value>
                </member>
                <member>
                  <name>Channel</name>
                  <value>#{ENV['SMS_GATEWAY_CHANNEL_ID']}</value>
                </member>
                <member>
                  <name>Priority</name>
                  <value>Bulk</value>
                </member>
                <member>
                  <name>MaxSegments</name>
                  <value>
                    <int>2</int>
                  </value>
                </member>
              </struct>
            </value>
          </param>
        </params>
      </methodCall>"

    service = SMSGateway.new
    xml = service.create_message "254722200200", "Hello World"
  end
end
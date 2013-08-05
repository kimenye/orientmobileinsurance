require 'test_helper'

class SMSGatewayTest < ActiveSupport::TestCase

  test "the gateway returns xml on success" do
    expected_response = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <methodResponse>
          <params>
            <param>
              <value>
          <struct>
            <member>
              <name>Identifier</name>
              <value><string>1ec78fd8</string></value>
            </member>
          </struct></value>
            </param>
          </params>
        </methodResponse>"

    service = SMSGateway.new
    response = service.send "254722200200", "Hello World"
    assert expected_response == response
  end

  test "The gateway response contains the transaction reference" do
    gateway_response =
        "<methodResponse>
          <params>
            <param>
              <value>
          <struct>
            <member>
              <name>Identifier</name>
              <value><string>1ec78fd8</string></value>
            </member>
          </struct></value>
            </param>
          </params>
        </methodResponse>"
    service = SMSGateway.new
    assert_equal "1ec78fd8", service.get_message_reference(gateway_response)
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
    assert xml == valid_xml
  end
end
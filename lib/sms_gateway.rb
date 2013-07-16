class SMSGateway

  def initialize
    @service_id = ENV['SMS_GATEWAY_SERVICE_ID']
    @channel_id = ENV['SMS_GATEWAY_CHANNEL_ID']
    @password = ENV['SMS_GATEWAY_PASSWORD']
    @base_uri = ENV['SMS_GATEWAY_URL']
  end

  def send to, message
    xml = create_message to, message
    response = ""

    if Rails.env == "production"
      options = {
          :body => xml
      }
      response = HTTParty.post( @base_uri, options).response
    else
      response = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
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
    end
    response
  end

  def create_message to, message
     xml = "<?xml version=\"1.0\"?>
      <methodCall>
        <methodName>EAPIGateway.SendSMS</methodName>
        <params>
          <param>
            <value>
              <struct>
                <member>
                  <name>Numbers</name>
                  <value>#{to}</value>
                </member>
                <member>
                  <name>SMSText</name>
                  <value>#{message}</value>
                </member>
                <member>
                  <name>Password</name>
                  <value>#{@password}</value>
                </member>
                <member>
                  <name>Service</name>
                  <value>
                    <int>#{@service_id}</int>
                  </value>
                </member>
                <member>
                  <name>Receipt</name>
                  <value>N</value>
                </member>
                <member>
                  <name>Channel</name>
                  <value>#{@channel_id}</value>
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
      xml
  end
end
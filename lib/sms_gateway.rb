class SMSGateway

  def initialize
    @service_id = ENV['SMS_GATEWAY_SERVICE_ID']
    @channel_id = ENV['SMS_GATEWAY_CHANNEL_ID']
    @password = ENV['SMS_GATEWAY_PASSWORD']
    @base_uri = ENV['SMS_GATEWAY_URL']
    @max_segment = ENV['SMS_MAX_SEGMENT_LENGTH'].to_i
    @split = ENV['SPLIT_SMS']
  end

  def send to, message
    begin
      segments = [message]
      if @split
        segments = split_message(message)
      end

      segments.each do |txt|
        xml = create_message to, txt
        response = ""
        puts ">>> Sent: #{txt} to #{to}"

        if Rails.env == "production"
          options = {
              :body => xml
          }
          response = HTTParty.post( @base_uri, options)
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
        resp = response.to_s
        Sms.create! :to => to, :text => txt, :request => xml,  :response => resp, :receipt_id => nil
      end
    rescue
    #  Do nothing
    end
  end
  
  def should_split_message message
    message.length > @max_segment
  end
  
  def split_message message
    message.chars.each_slice(@max_segment).map(&:join)
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
                  <value>Urgent</value>
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
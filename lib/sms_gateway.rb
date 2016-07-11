require 'json'
class SMSGateway

  def self.send to, message
    begin
      url = ENV['SMS_GATEWAY_URL']
      auth = { :username => ENV['SMS_GATEWAY_USERNAME'], :password => ENV['SMS_GATEWAY_PASSWORD'] }

      body = {
        :MSISDN => to,
        :Content => message,
        :Shortcode => ENV['SMS_GATEWAY_SHORT_CODE'],
        :CampaignID => ENV['SMS_GATEWAY_CAMPAIGN_ID'],        
        :Premium => '1',
        :Channel => 'KENYA.SAFARICOM',
        :Multitarget => '1'
      }

      response_id = nil
      response_string = nil

      if Rails.env == "production"
        response = HTTParty.post(url, body, :basic_auth => auth )
        # 101\nMessage accepted\n12.2283.1468236299.3
        results = response.split("\n")
        response_id = results.last
        response_string = response.body
      end
      Sms.create! :to => to, :text => message, :request => nil,  :response => response_string, :receipt_id => response_id
    rescue
      # do nothing
    end
  end

  def self.old_send to, message, mode='default'
    begin
      segments = [message]
      if ENV['SPLIT_SMS']
        segments = self.split_message(message)
      end

      segments.each do |txt|
        xml = self.create_message to, txt, mode
        response = ""

        if Rails.env == "production"
          options = {
              :body => xml,
              :headers => { "content-type" => "text/xml;charset=utf8" }
          }

          response = HTTParty.post(ENV['SMS_GATEWAY_URL'], options)
        else
          response = {"methodResponse"=>
            {"params"=>
              {"param"=>
                {"value"=>
                  {"struct"=>
                    {"member"=>
                      {"name"=>"Identifier", "value"=>{"string"=>"365d6a84"}}}}}}}}
        end
        resp = response.to_s
        receipt_id = response["methodResponse"]["params"]["param"]["value"]["struct"]["member"]["value"]["string"]
        Sms.create! :to => to, :text => txt, :request => xml,  :response => resp, :receipt_id => receipt_id
      end
    rescue
    #  Do nothing
    end
  end
  
  def self.should_split_message message
    message.length > ENV['SMS_MAX_SEGMENT_LENGTH'].to_i
  end
  
  def self.split_message message
    message.chars.each_slice(ENV['SMS_MAX_SEGMENT_LENGTH'].to_i).map(&:join)
  end

  def self.create_message to, message, mode="default"
    channel = mode == 'default' ? ENV['SMS_GATEWAY_CHANNEL_ID'] : ENV['SMS_GATEWAY_AIRTEL_CHANNEL_ID']
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
                  <value>#{ENV['SMS_USE_RECEIPTS']}</value>
                </member>
                <member>
                  <name>Channel</name>
                  <value>#{channel}</value>
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
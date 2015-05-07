class SmsService

  def self.payment_instructions account_name, expiry, enquiry_type="omb"
    if enquiry_type == "Airtel"
      message = "Please pay via Airtel Money (Business Name -). Your account no. #{account_name} is valid till #{expiry.utc.to_s(:full)}."
    else
      message = "Please pay via MPesa (Business No. #{ENV['MPESA']}) or Airtel Money (Business Name #{ENV['AIRTEL']}). Your account no. #{account_name} is valid till #{expiry.utc.to_s(:full)}."                      
    end
    message
  end

  def self.handle_sms_sending(text, mobile)

    premium_service = PremiumService.new

    msg_type = premium_service.get_message_type text
    
    @message = Message.new
    @message.phone_number = mobile
    @message.status = "Received"
    @message.text = text
    @message.message_type = msg_type
    @message.save!


    Rails.logger.debug ">>> message type #{msg_type}"
    if msg_type == 1
      enquiry = Enquiry.new
      enquiry.phone_number = mobile
      enquiry.text = text
      enquiry.date_of_enquiry = Time.now
      enquiry.source = "SMS"
      enquiry.hashed_phone_number = Digest::MD5.hexdigest(mobile)
      enquiry.hashed_timestamp = Digest::MD5.hexdigest(Time.now.to_s)

      url = "#{ENV['BASE_URL']}enquiries/#{enquiry.hashed_phone_number}/#{enquiry.hashed_timestamp}"      
      if Rails.env.production?
        auth = UrlShortener::Authorize.new ENV['BITLY_USERNAME'], ENV['BITLY_PASSWORD']
        client = UrlShortener::Client.new auth
        result = client.shorten(url)
        url = result.result['nodeKeyVal']['shortUrl']
      end

      enquiry.url = url
      enquiry.save!
      SMSGateway.send(enquiry.phone_number, "Click here to access Orient Mobile: #{enquiry.url}")
    elsif msg_type == 2
      #user is sending an imei number
      PremiumService.activate_policy! text, mobile
    else
      Rails.logger.debug ">>> we were not able to understand the text message"
    end

    return @message

  end

end
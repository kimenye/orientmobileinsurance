class SmsService

  def handle_sms_sending(text, mobile)

    @gateway = SMSGateway.new
    premium_service = PremiumService.new

    msg_type = premium_service.get_message_type text
    
    @message = Message.new
    @message.phone_number = mobile
    @message.status = "Received"
    @message.text = text
    @message.message_type = msg_type
    @message.save!


    Rails.logger.info ">>> message type #{msg_type}"
    if msg_type == 1
      enquiry = Enquiry.new
      enquiry.phone_number = mobile
      enquiry.text = text
      enquiry.date_of_enquiry = Time.now
      enquiry.source = "SMS"
      enquiry.hashed_phone_number = Digest::MD5.hexdigest(mobile)
      enquiry.hashed_timestamp = Digest::MD5.hexdigest(Time.now.to_s)

      url = "#{ENV['BASE_URL']}enquiries/#{enquiry.hashed_phone_number}/#{enquiry.hashed_timestamp}"
      enquiry.url = url
      if Rails.env == "production"
        auth = UrlShortener::Authorize.new ENV['BITLY_USERNAME'], ENV['BITLY_PASSWORD']
        client = UrlShortener::Client.new auth
        result = client.shorten(url)
        shortened_url = result.result['nodeKeyVal']['shortUrl']

        enquiry.url = shortened_url
      end
      enquiry.save!
      @gateway.send(enquiry.phone_number, "Click here to access Orient Mobile: #{enquiry.url}")
    elsif msg_type == 2
      #user is sending an imei number
      premium_service.activate_policy text, mobile
    else
      Rails.logger.info ">>> we were not able to understand the text message"
    end

    return @message

  end

end
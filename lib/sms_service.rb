class SmsService

  def handle_sms_sending(text, mobile)

    @gateway = SMSGateway.new
    premium_service = PremiumService.new

    #puts ">>> Params #{params}"
    msg_type = premium_service.get_message_type text
    
    @message = Message.new
    @message.phone_number = mobile
    @message.status = "Received"
    @message.text = text
    @message.message_type = msg_type
    @message.save!


    puts ">>> message type #{msg_type}"
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
        puts ">>>>  in production"
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
      device = InsuredDevice.find_by_imei(text)
      if !device.nil?
        quote = Quote.create! quote_type: "Corporate"
        customer = Customer.find_or_create_by_phone_number! phone_number: mobile, name: "name", email: "email", id_passport: "id"
        quote.customer_id = customer.id
        quote.insured_device_id = device.id
        quote.save!
        device.customer_id = customer.id
        device.save!
        if !device.activated?
          hashed_phone_number = Digest::MD5.hexdigest(mobile)
          url = "#{ENV['BASE_URL']}prepaid_devices/customer_details?number=#{hashed_phone_number}&imei=#{text}"
          if Rails.env == "production"
            puts ">>>>  in production"
            auth = UrlShortener::Authorize.new ENV['BITLY_USERNAME'], ENV['BITLY_PASSWORD']
            client = UrlShortener::Client.new auth
            result = client.shorten(url)
            shortened_url = result.result['nodeKeyVal']['shortUrl']
            @gateway.send(mobile, "Click here to complete your policy confirmation: #{shortened_url}")
          end
          @gateway.send(mobile, "Click here to complete your policy confirmation: #{url}")
          customer.hashed_phone_number = hashed_phone_number
          customer.save!
        else 
          @gateway.send(mobile, "Sorry, that imei number has already been used. Please send the imei again.")
        end
      else
        premium_service.activate_policy text, mobile
      end
    else
      puts ">>> we were not able to understand the text message"
    end

    return @message

  end

end
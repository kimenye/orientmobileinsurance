require 'digest/md5'
require 'sms_gateway'
require 'url_shortener'

class MessagesController < ApplicationController

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all

    respond_to do |format|
      #format.html # index.html.erb
      format.all { render json: @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @message = Message.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/new
  # GET /messages/new.json
  def new
    @message = Message.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])
  end

  def receipts
    puts ">>>> #{params.has_key?(:receipts)} <<< Params - #{params}"
    if params.has_key? (:receipts)
      if params[:receipts][:receipt].kind_of? Array
        params[:receipts][:receipt].each do |receipt|
          receipt_id = receipt[:reference]
          delivered = receipt[:status]
          sms = Sms.find_by_receipt_id receipt_id
          if !sms.nil?
            sms.delivered = delivered == "D"
            sms.save!
          end
        end
      else
        if params[:receipts][:receipt].any?
          receipt = params[:receipts][:receipt]
          receipt_id = receipt[:reference]
          delivered = receipt[:status]
          sms = Sms.find_by_receipt_id receipt_id
          if !sms.nil?
            sms.delivered = delivered == "D"
            sms.save!
          end
        end
      end
    end
    render text: "OK"
  end

  def create2
    puts ">>> New submit path #{params}"
    if params.has_key?(:msisdn) && params.has_key?(:text)


      text = params[:text].strip
      number = params[:msisdn]
      if !number.starts_with?("+")
        number = "+#{number}"
      end

      if text.downcase.starts_with?("omi")  
        
        text = text.downcase.gsub /omi/, ''      
        prefix = "OMI"
        
        premium_service = PremiumService.new
        @gateway = SMSGateway.new
        msg_type = premium_service.get_message_type prefix, text        
        
        @message = Message.new
        @message.phone_number = number
        @message.status = "Received"
        @message.text = text
        @message.message_type = msg_type
        @message.save!
        
        puts ">>> message type #{msg_type}"
        if msg_type == 1
          enquiry = Enquiry.new
          enquiry.phone_number = number
          enquiry.text = prefix
          enquiry.date_of_enquiry = Time.now
          enquiry.source = "SMS"
          enquiry.hashed_phone_number = Digest::MD5.hexdigest(number)
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
          puts ">>> user is sending an imei number"
          premium_service.activate_policy text, number
        else
          puts ">>> we were not able to understand the text message"
        end
        
      end
    end
    render text: "OK"
  end

  # POST /messages
  # POST /messages.json
  def create

    begin
      @gateway = SMSGateway.new
      premium_service = PremiumService.new

      puts ">>> Params #{params}"
      prefix = params["Prefix"]
      text = params["Text"]
      msg_type = premium_service.get_message_type prefix, text
      mobile = params["MobileNumber"]

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
        enquiry.text = prefix
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
        premium_service.activate_policy text, mobile
      else
        puts ">>> we were not able to understand the text message"
      end

      respond_to do |format|
        format.all { render json: @message, status: :created, location: @message }
      end
    rescue => error
      puts ">>>>> in error #{error}"
      respond_to do |format|
        format.all { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.json
  def update
    @message = Message.find(params[:id])

    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url }
      format.json { head :no_content }
    end
  end
end

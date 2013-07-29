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

  # POST /messages
  # POST /messages.json
  def create

    begin

      @gateway = SMSGateway.new

      @message = Message.new
      @message.phone_number= params["MobileNumber"]
      @message.status = "Received"
      @message.text = params["Prefix"]
      @message.message_type = 1
      @message.save!

      enquiry = Enquiry.new
      enquiry.phone_number = params["MobileNumber"]
      enquiry.text = params["Prefix"]
      enquiry.date_of_enquiry = Time.now
      enquiry.source = "SMS"
      enquiry.hashed_phone_number = Digest::MD5.hexdigest(params["MobileNumber"])

      url = "#{ENV['BASE_URL']}enquiries/#{enquiry.hashed_phone_number}"
      auth = UrlShortener::Authorize.new ENV['BITLY_USERNAME'], ENV['BITLY_PASSWORD']
      client = UrlShortener::Client.new auth
      result = client.shorten(url)
      shortened_url = result.result['nodeKeyVal']['shortUrl']

      enquiry.url = shortened_url
      enquiry.save!

      @gateway.send(enquiry.phone_number, "Click here to access Orient Mobile: #{shortened_url}")
      respond_to do |format|
        format.all { render json: @message, status: :created, location: @message }
      end
    rescue => error
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

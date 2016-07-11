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
    # puts ">>> Params: #{params} <<<"
    sms = Sms.find_by_receipt_id params[:Reference]
    if !sms.nil?
      sms.delivered = params[:Status] == 'DELIVRD'
      date_time = Time.at(params[:DateDelivered].to_i).to_datetime
      sms.time_of_delivery = date_time
      sms.save!
    end
    render text: 'OK'
  end

  # POST /messages
  # POST /messages.json
  def create

    begin

      text = params["Content"]

      if !text.downcase.start_with?("test")
        mobile = params["MSISDN"]
        if !mobile.start_with?("+")
          mobile = "+#{mobile}"
        end

        service = SmsService.new

        @message = SmsService.handle_sms_sending(text, mobile)

        render text: 'OK'
      else
        if Rails.env == "production"
          msg = text.split(" ")[1]
          HTTParty.post(ENV['DEVELOPEMENT_SERVER_URL'], :query => { "Content" => msg, "MSISDN" => params["MSISDN"] })
        end
        render text: "OK"
      end
    rescue => error      
      respond_to do |format|
        format.all { render json: (@message.errors if !@message.nil?), status: :unprocessable_entity }
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

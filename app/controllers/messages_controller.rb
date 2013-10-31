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

  # POST /messages
  # POST /messages.json
  def create

    begin

      text = params["Text"]
      mobile = params["MobileNumber"]
      service = SmsService.new

      @message = service.handle_sms_sending(text, mobile)

      respond_to do |format|
        format.all { render json: @message, status: :created, location: @message }
      end
    rescue => error
      puts ">>>>> in error #{error}"
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

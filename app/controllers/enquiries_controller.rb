class EnquiriesController < ApplicationController
  def show
    id = Integer(params[:id]) rescue nil
    @enquiry = nil
    if id.nil?
      @enquiry = Enquiry.find_by_hashed_phone_number(params[:id])
    else
      @enquiry = Enquiry.find(params[:id])
    end
    session[:enquiry_id] = @enquiry.id
    redirect_to enquiry_index_path
  end

  def new_claim
    status = Status.new
    status.action = "new-claim"
    session[:status] = status
    redirect_to status_path
  end

  def enquire_status
    status = Status.new
    status.action = "new-status"
    session[:status] = status
    redirect_to status_path
  end

  def send_sms
    #binding.pry
    @gateway = SMSGateway.new
    begin
      @gateway.send(params[:phone_number], params[:message])
      respond_to do |format|
        format.all { render json: {success: "Message Sent"}, status: :ok }
      end
    rescue => error
      respond_to do |format|
        format.all { render json: {error: "SMS could not be sent"}, status: :bad_gateway }
      end
    end
  end
end

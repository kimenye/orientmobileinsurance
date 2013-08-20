class EnquiriesController < ApplicationController
  def show
    id = Integer(params[:hashed_phone_number]) rescue nil
    @enquiry = nil
    if id.nil?
      @enquiry = Enquiry.find_by_hashed_phone_number_and_hashed_timestamp(params[:hashed_phone_number], params[:hashed_timestamp])
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
end

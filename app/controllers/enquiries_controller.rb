class EnquiriesController < ApplicationController
  def show
    id = Integer(params[:hashed_phone_number]) rescue nil
    @enquiry = nil
    if id.nil?
      @enquiry = Enquiry.find_by_hashed_phone_number_and_hashed_timestamp(params[:hashed_phone_number], params[:hashed_timestamp])
    else
      @enquiry = Enquiry.find(params[:id])
    end

    if @enquiry.nil?
      session[:enquiry_id] = nil
      logger.info "Redirecting to start again path session: #{session} params: #{params}"
      redirect_to start_again_path
    else
      session[:enquiry_id] = @enquiry.id
      redirect_to enquiry_index_path
    end
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
    status.enquiry_type = params[:enquiry_type]
    session[:status] = status
    redirect_to status_path
  end
end

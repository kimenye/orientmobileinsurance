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
    binding.pry
    session[:action] = "new-claim"
    redirect_to status_path
  end
end

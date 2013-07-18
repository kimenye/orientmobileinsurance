class EnquiryController < ApplicationController
  layout "mobile"

  def index
    @enquiries = Enquiry.all
  end

  def show
    id = Integer(params[:id]) rescue nil
    @enquiry = nil
    if id.nil?
      @enquiry = Enquiry.find_by_hashed_phone_number(params[:id])
    else
      @enquiry = Enquiry.find(params[:id])
    end
  end

  def update
    @enquiry = Enquiry.find(params[:id])
    if @enquiry.update_attributes(params[:enquiry])
      redirect_to enquiries_path, :notice => "Enquiry updated."
    else
      redirect_to enquiries_path, :alert => "Unable to update enquiry."
    end
  end

  def destroy
    @enquiry = Enquiry.find(params[:id])
    @enquiry.destroy
    redirect_to enquiries_path, :notice => "Enquiry deleted."
  end

  def create
    @enquiry = Enquiry.new
    @enquiry.attributes = params[:enquiry]
    @enquiry.save
    redirect_to enquiries_path, :notice => "Enquiry created"
  end

end

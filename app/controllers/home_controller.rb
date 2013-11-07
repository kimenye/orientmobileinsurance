class HomeController < ApplicationController
  def index
    if user_signed_in?
      @users = User.all
      @claims = Claim.all
      render 'user'
    else
      render 'index'
    end
  end

  def device
    render :layout => "mobile"
  end

  def result
    device_data = get_device_data

    vendor = device_data["vendor"]
    marketingName = device_data["marketingName"]
    add_client_properties! device_data
    model = get_model_name device_data
    device = Device.model_search(vendor, model).first
    @device = Enquiry.new
    @device.model = model
    @device.vendor = vendor
    @device.marketing_name = marketingName

    @device.detected = !device.nil?
    @catalogue_device = device
  end
end

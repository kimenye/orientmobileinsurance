require 'deviceatlasapi'
class HomeController < ApplicationController
  include DeviceAtlasApi::ControllerHelpers

  def index
    @users = User.all
    @claims = Claim.all
  end

  def device
    render :layout => "mobile"
  end

  def result
    device_data = get_device_data
    #Check for the devices among our supported devices
    model = device_data["model"]
    vendor = device_data["vendor"]
    marketingName = device_data["marketingName"]

    invalid_da = (vendor.nil? || vendor.empty?) && (model.nil? || model.empty?)

    iphone_5 = request.cookies["device.isPhone5"]
    if iphone_5 == "true"
       model = "IPHONE 5"
    end

    @device = Enquiry.new
    @device.model = model
    @device.vendor = vendor
    @device.marketing_name = marketingName

    if !invalid_da
      device = Device.device_similar_to(vendor, model, Device.get_marketing_search_parameter(marketingName)).first

      puts ">> Device is nil ? #{device.nil?}"

      if device.nil?
        device = Device.wider_search(model).first
      end
    end

    puts ">> After device is nil ? #{device.nil?}"
    @device.detected = !device.nil?

    @catalogue_device = device
  end
end

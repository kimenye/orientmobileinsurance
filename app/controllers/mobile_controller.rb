#require 'pry'
require 'premium_service'
require 'deviceatlasapi'

class MobileController < ApplicationController

  layout "mobile"

  include DeviceAtlasApi::ControllerHelpers

  def index

  end

  def secure

  end

  def status_check

    @service = PremiumService.new

    @is_insurable = @service.is_insurable(params[:year_of_purchase], params[:sales_agent_code])

    @year_of_purchase = params[:year_of_purchase]

    #@device_info = get_device_info

    #Commented out the above as it wasnt working. Havent set the DEVICE_ATLAS_LICENCE_KEY


    render 'status'

    #binding.pry

  end
end

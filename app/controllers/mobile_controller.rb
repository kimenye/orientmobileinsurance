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

    @device_info = get_device_data

    render 'status'
  end
end

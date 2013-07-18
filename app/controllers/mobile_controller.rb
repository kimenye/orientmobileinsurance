#require 'pry'
require 'premium_service'

class MobileController < ApplicationController

  layout "mobile"

  def index

  end

  def secure

  end

  def status_check

    @service = PremiumService.new

    is_insurable = @service.is_insurable(params[:year_of_purchase], params[:sales_agent_code])


    #binding.pry

  end
end

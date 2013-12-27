class AdminController < ApplicationController
  # before_filter :sauthenticate_user!
  include ActionView::Helpers::NumberHelper

  def index
  	
  end

  def calculator
  	# binding.pry
  	device = params[:quote][:device]
  	yop = params[:quote][:year_of_purchase]
  	sales_agent_code = params[:quote][:agent_code]

  	d = Device.find_by_id(device)
  	
  	iv = d.get_insurance_value(sales_agent_code, yop.to_i)

  	premium_service = PremiumService.new

  	annual_premium = premium_service.calculate_annual_premium(sales_agent_code, iv, yop.to_i)
    installment_premium = premium_service.calculate_monthly_premium(sales_agent_code, iv, yop.to_i)

  	respond_to do |format|
  		format.json { render json: {:success => true, 
  			:insurance_value => number_to_currency(iv, :unit => "KES ", :precision => 0, :delimiter => ","), 
  			:annual_premium => number_to_currency(annual_premium, :unit => "KES ", :precision => 0, :delimiter => ","), 
  			:installment_premium => number_to_currency(installment_premium, :unit => "KES ", :precision => 0, :delimiter => ","), 
  			:retail_price => number_to_currency(d.catalog_price, :unit => "KES ", :precision => 0, :delimiter => ","), 
  			:device => d.stock_code, 
  			:annual_premium => number_to_currency(annual_premium, :unit => "KES ", :precision => 0, :delimiter => ",") 
  		}, status: :created}
  	end
  end
end
class QuotesController < ApplicationController
	def new
	end

	def index
	end

	def show
		@quote = Quote.find(params[:id])
	end

	def create
		
		quote = params[:quote]
		
		customer = Customer.find_by_id_passport(quote[:company_pin])
		if customer.nil?
			customer = Customer.new({:id_passport => quote[:company_pin]})
		end
		customer.company_name = quote[:company_name]
		customer.name = quote[:contact_person]
		customer.email = quote[:email_address]
		customer.customer_type = "Corporate"
		customer.phone_number = quote[:mobile_number]

		customer.save!

		premium_service = PremiumService.new
		
		@quote = Quote.new(:quote_type => "Corporate", :premium_type => "Annual", :annual_premium => 0, :customer_id => customer.id, :insured_value => 0, :expiry_date => 3.days.from_now)
		@quote.account_name = "OMB#{premium_service.generate_unique_account_number}"
		@quote.save!

		quote[:device].each do |device|
			d = device[1]
			dev = Device.find_by_id(d[:id].to_i)

  			iv = dev.get_insurance_value(quote[:sales_agent_code], d[:yop].to_i)  			
  			annual_premium = premium_service.calculate_annual_premium(quote[:sales_agent_code], iv, d[:yop].to_i)
  			id = InsuredDevice.new({ :premium_value => annual_premium, :customer_id => customer.id, :device_id => dev.id,
  				:imei => d[:imei], :phone_number => d[:phone_number], :insurance_value => iv, :quote_id => @quote.id, :yop => d[:yop].to_i })
  			id.save!

  			@quote.annual_premium += annual_premium
  			@quote.insured_value += iv
		end
		
		@quote.save!

		# @quote = Quote.first


		respond_to do |format|
			format.html { redirect_to quote_path(@quote), notice: 'Quote was successfully updated.' }
		end
	end
end
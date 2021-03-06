class QuotesController < ApplicationController
	respond_to :xls, :html
	def new
	end

	def index
	end

	def show
		@quote = Quote.find(params[:id])
	end

	def update
		@quote = Quote.find(params[:id])
		payment = params[:payment]

		service = PaymentService.new()
		service.handle_payment(@quote.account_name, payment[:amount], payment[:transaction_ref], "Cheque")


		respond_to do |format|
			format.html { redirect_to quote_path(@quote), notice: 'Payment was updated.' }
		end
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
		customer.lead = false
		customer.phone_number = quote[:mobile_number]

		customer.save!

		premium_service = PremiumService.new
		
		@quote = Quote.new(:quote_type => "Corporate", :premium_type => "Annual", :annual_premium => 0, :agent_id => quote[:sales_agent_code], :customer_id => customer.id, :insured_value => 0, :expiry_date => 3.days.from_now)
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
		email = CustomerMailer.corporate_quotation(@quote).deliver
		
		respond_to do |format|
			format.html { redirect_to quote_path(@quote), notice: 'Quote was successfully updated.' }
		end
	end

	def download_pdf
		@quote = Quote.find(params[:id])
		send_data generate_pdf(@quote),
		          filename: "quote.pdf",
		          type: "application.pdf"
	end


	def download_xlsx
		@quote = Quote.find(params[:id])
		respond_to do |format|
			format.xlsx {
		    	# response.headers['Content-Disposition'] = 'attachment; filename="quote_#{@quote.account_name}.xlsx"'
		    	  render xlsx: "download_xlsx", disposition: "attachment", filename: "quote_#{@quote.account_name}.xlsx"
			}
	    end
	end

	def generate_pdf(quote)
		AttachmentService.generate_pdf(quote).render		
	end
end
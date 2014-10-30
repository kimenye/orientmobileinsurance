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

	def upload_page
	  
	end

	def upload_policy_details
	  file = params[:file]
	  if params[:file].is_a? ActionDispatch::Http::UploadedFile
	  	file = params[:file].tempfile
	  end
	  doc = SimpleXlsxReader.open(file)          
      data = doc.sheets.first.rows[1..doc.sheets.first.rows.length]
      premium_service = PremiumService.new
      sms_gateway = SMSGateway.new
      # [[id_no, name, phone_number, email, model, imei, agent_code, annual_premium, insured_value]]
      data.each do |data|
      	device = Device.find_by_model(data[4])
      	customer = Customer.find_or_create_by_id_passport! name: data[1], id_passport: data[0], email: data[3], phone_number: data[2]
      	insured_device = InsuredDevice.create! customer_id: customer.id, device_id: device.id, imei: data[5], yop: Time.now.year, phone_number: customer.phone_number, insurance_value: data[8]
      	quote = Quote.create!(account_name: "OMB#{premium_service.generate_unique_account_number}", annual_premium: data[7], expiry_date: 1.year.from_now, insured_device_id: insured_device.id, 
      		premium_type: "Prepaid", insured_value: data[8], agent_id: Agent.find_by_code(data[6]).id, customer_id: customer.id, quote_type: "Individual")
      	policy = Policy.create! expiry: 1.year.from_now, policy_number: premium_service.generate_unique_policy_number, start_date: Time.now, status: "Active", quote_id: quote.id, insured_device_id: insured_device.id
      	
      	insured_value_str = ActionController::Base.helpers.number_to_currency(policy.quote.insured_value, :unit => "KES ", :precision => 0, :delimiter => "")
      	sms_gateway.send customer.phone_number, "You have successfully covered your device, value #{insured_value_str}. Orient Mobile policy #{policy.policy_number} valid till #{policy.expiry.to_s(:simple)}. Policy details: #{ENV['OMB_URL']}"
      	email = CustomerMailer.policy_purchase(policy).deliver
      end
	  redirect_to 'upload_page', notice: "Details uploaded successfully."
	end
end
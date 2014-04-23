class PolicyService
	def self.create_corporate_policy(customer_name, customer_id, email, phone_number, policy_type, sales_agent_code, payment_mode, model, 
		purchase_date, insured_value, replacement_value, amount_paid, payment_ref, imei, cover_start_date, cover_end_date)

		premium_service = PremiumService.new

		# first check if the customer exists
		customer = Customer.find_by_id_passport(customer_id)
		if customer.nil?
			customer = Customer.create! :name => customer_name, :id_passport => customer_id, :email => email, :phone_number => "+#{phone_number}", :lead => false
		end
		# binding.pry
		agent = Agent.find_by_code(sales_agent_code)

		device = Device.find_by_model(model)

		insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => device.id, :imei => imei, :yop => Time.now.year, :phone_number => "+#{phone_number}"
    	quote = Quote.create! :insured_device_id => insured_device.id, :insured_value => insured_value, :premium_type => policy_type, :annual_premium => amount_paid, :monthly_premium => nil, :account_name => "", :expiry_date => 3.days.from_now, :agent_id => (agent.id if !agent.nil?)
    	policy = Policy.create! :policy_number => premium_service.generate_unique_policy_number, :quote_id => quote.id, :status => "Active", :start_date => cover_start_date, :expiry => cover_end_date
    	payment = Payment.create! :method => payment_mode, :policy_id => policy.id, :amount => amount_paid, :reference => payment_ref
	end
end
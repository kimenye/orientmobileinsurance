ActiveAdmin.register_page "Simulator" do

  #menu :parent => "Simulator"

  page_action :payment, :method => :post do
    service = PaymentService.new

    channel = params["payment"]["channel"]
    account_id = params["payment"]["account_name"]
    amount = params["payment"]["amount"]
    transaction_ref = params["payment"]["transaction_ref"]


    result = service.handle_payment(account_id, amount, transaction_ref, channel)

    if result
      redirect_to admin_simulator_path, :notice => "Payment was successfully made"
    else
      redirect_to admin_simulator_path, :notice => "Payment failed"
    end

  end

  page_action :message, :method => :post do
    text = params["sms"]["text"]
    mobile = params["sms"]["phone_number"]

    SMSGateway.send mobile, text
    redirect_to admin_simulator_path, :notice => "SMS sent"
  end

  page_action :sms, :method => :post do

    text = params["sms"]["text"]
    mobile = params["sms"]["phone_number"]

    begin
      SmsService.handle_sms_sending(text, mobile)
      redirect_to admin_simulator_path, :notice => "Message was received"
    rescue
      redirect_to admin_simulator_path, :notice => "Message was not received"
    end
  end

  page_action :send_reminders, :method => :post do
    # reminder_service = ReminderService.new
    count = ReminderService.send_reminders
    redirect_to admin_simulator_path, :notice => "Sent #{count} Reminders"
  end

  page_action :add_bulk_payment, :method => :post do
    code = params["payment"]["code"]
    amount = params["payment"]["amount"]

    bp = BulkPayment.create! :code => code, :amount_required => amount
    redirect_to admin_simulator_path, :notice => "Bulk Payment created #{bp.code}"
  end

  page_action :change_expiry, :method => :post do
    expired_policies = Policy.where("expiry < ?", ReminderService._get_start_of_day(Time.now))    
    count = 0
    expired_policies.each do |policy|
      if !policy.has_claim?  
        policy.expiry = ReminderService._get_end_of_day(1.day.from_now)
        policy.save!
        count += 1
      end      
    end
    redirect_to admin_simulator_path, :notice => "Changed #{count} expiry dates"
  end

  page_action :external_policy,  method: :post do
    customer_name = params['policy']['customer_name']
    agent_code = params['policy']['agent_code']
    phone_number = params['policy']['phone_number']
    id = params['policy']['id']
    imei = params['policy']['imei']
    email = params['policy']['email_address']

    device_id = params['policy']['device']['0']['id']
    device = Device.find(device_id)

    sum_insured = params['policy']['sum_insured']
    premium_paid = params['policy']['premium_paid']
    yop = params['policy']['yop']
    payment_ref = params['policy']['payment_ref']

    customer = Customer.find_or_create_by_id_passport_and_name_and_email_and_phone_number!(id, customer_name, email, phone_number)
    customer.customer_type = 'Individual' if customer.customer_type.blank?    
    customer.save!

    agent = Agent.find_by_code(agent_code).try(:id)

    # create a quote
    premium_service = PremiumService.new
    
    quote = Quote.new(:quote_type => "Individual", :premium_type => "Annual", :annual_premium => premium_paid, :agent_id => agent, :customer_id => customer.id, :insured_value => sum_insured, :expiry_date => 3.days.from_now)
    quote.account_name = "OMB#{premium_service.generate_unique_account_number}"
    quote.save!
    
    id = InsuredDevice.new({ :premium_value => premium_paid, :customer_id => customer.id, :device_id => device.id,
          :imei => imei, :phone_number => phone_number, :insurance_value => sum_insured, :quote_id => quote.id, :yop => yop.to_i })
    id.save!

    quote.insured_device_id = id.id
    quote.save!

    service = PaymentService.new()
    service.handle_payment(quote.account_name, premium_paid, payment_ref, "Agent")

    policy = Policy.last

    redirect_to admin_simulator_path, notice: "Created policy #{policy.policy_number}" 
  end



  page_action :generate_quote, method: :post do
    customer_name = params["quote"]["customer_name"]
    customer_id = params["quote"]["id"]
    email = params["quote"]["email_address"]
    code = params["quote"]["sales_agent_code"]

    yop = params["quote"]["year_of_purchase"].to_i
    payment_option = params["payment_option"]
    mop = params["month_of_purchase"]
    phone_number = params["quote"]["phone_number"]
    device_id = params["quote"]["device"]["0"]["id"]

    device = Device.find(device_id)

    # iv = device.get_insurance_value(code, yop)
    iv = device.get_insurance_value_by_month_and_year(code, mop, yop)

    premium_service = PremiumService.new

    annual_premium = premium_service.calculate_annual_premium(code, iv, yop)
    installment_premium = premium_service.calculate_monthly_premium(code, iv, yop)
    six_monthly_premium = premium_service.calculate_monthly_premium(code, iv, yop, 6)

    if params["payment_option"] == "Monthly"
      premium_value = premium_service.calculate_monthly_premium(code, iv, yop)
      premium_type = "Monthly"
    elsif params["payment_option"] == "Six Monthly"
      premium_type = "six_monthly"
      premium_value = premium_service.calculate_monthly_premium(code, iv, yop, 6)
    else
      premium_type = "Annual"
    end

    customer = Customer.find_by_id_passport(customer_id)

    if(customer.nil?)
      customer = Customer.create!(:name => customer_name, :id_passport => customer_id, :email => email, :phone_number => phone_number)
    end

    agent = Agent.find_by_code(code)
    agent_id = nil
    if !agent.nil?
      agent_id = agent.id
    end

    account_name = "OMB#{premium_service.generate_unique_account_number}"

    insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => device_id, :yop => yop, :phone_number => phone_number, :insurance_value => iv
    q = Quote.create!(:account_name => account_name, :annual_premium => annual_premium,
                      :expiry_date => 72.hours.from_now,
                      :monthly_premium => premium_value,
                      :premium_type => premium_type,
                      :insured_device_id => insured_device.id,
                      :insured_value => iv,
                      :agent_id => agent_id, :customer_id => customer.id, :quote_type => "Individual")

    
    SMSGateway.send(phone_number, "#{device.marketing_name}, Year #{yop}. Insurance Value is #{ActionController::Base.helpers.number_to_currency(iv, :unit => 'KES ', :precision => 0, :delimiter => '')}. Payment due is #{ActionController::Base.helpers.number_to_currency(annual_premium, :unit => 'KES ', :precision => 0, :delimiter => '')}")
    SMSGateway.send(phone_number, SmsService.payment_instructions(account_name, q.expiry_date))

    redirect_to admin_simulator_path, :notice => "#{customer_name}, #{iv}"
  end

  page_action :expire_policy, method: :post do
    policy = Policy.find(params[:id])
    policy.status = "Expired"
    policy.save!

    redirect_to admin_simulator_path, notice: "#{policy.policy_number} has been finalized"
  end

  content do

    columns do
      column do
        render "index"
      end

      column do
        render "message"
      end
    end

    columns do
      column do
        render "sms"
      end
      column do
        render "add_bulk_payment"
      end
    end

    columns do
      column do
        render "generate_quote"
      end
      column do
        render 'external_policy'
      end
    end

    columns  do
      # reminder_service = ReminderService.new
      column do        
        today = ReminderService.get_policies_expiring_in_duration(0)
        h3 "Policies Expiring Today"
        table_for today, :class=> "index_table" do |p|
          column "Customer" do |p|
            p.customer.name
          end
          column "Number" do |p|
            p.quote.insured_device.phone_number
          end
          column "Policy Number" do |p|
            p.policy_number
          end
          column "Expiry Date" do |p|
            p.expiry.to_s(:simple)
          end
        end        
      end
      column do
        today = ReminderService.get_policies_expiring_in_duration(2)
        h3 "Policies Expiring In 3 days"
        table_for today, :class=> "index_table" do |p|
          column "Customer" do |p|
            p.customer.name
          end
          column "Number" do |p|
            p.quote.insured_device.phone_number
          end
          column "Policy Number" do |p|
            p.policy_number
          end
          column "Expiry Date" do |p|
            p.expiry.to_s(:simple)
          end
        end   
      end
    end

    columns do
      column do
        render "form"
      end
    end    

    columns do
      column do
        h3 "Lapsed Policies"
        policies = Policy.where("expiry < ?", ReminderService._get_start_of_day(Time.now)).order('expiry DESC')
        table_for policies, :class=> "index_table" do |p|
          column "Customer" do |p|
            p.try(:customer).name            
          end
          column "Number" do |p|
            p.quote.insured_device.phone_number if !p.quote.insured_device.nil?
          end
          column "Policy Number" do |p|
            p.policy_number
          end
          column "Expiry Date" do |p|
            p.expiry.to_s(:simple)
          end
          column do |p|
            link_to 'End Policy', "#{admin_simulator_expire_policy_path}?id=#{p.id}", confirm: 'Are you sure you want to end the policy?', method: :post
          end
        end 
        # render "update"
      end
    end
  end

end
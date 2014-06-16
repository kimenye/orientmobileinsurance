ActiveAdmin.register_page "Simulator" do

  #menu :parent => "Simulator"

  page_action :payment, :method => :post do
    puts ">>>> #{params}"
    #All payments are from MPESA
    #create a random transaction ref

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

    gateway = SMSGateway.new
    gateway.send mobile, text
    redirect_to admin_simulator_path, :notice => "SMS sent"
  end

  page_action :sms, :method => :post do

    text = params["sms"]["text"]
    mobile = params["sms"]["phone_number"]
    service = SmsService.new

    begin
      service.handle_sms_sending(text, mobile)
      redirect_to admin_simulator_path, :notice => "Message was received"
    rescue
      redirect_to admin_simulator_path, :notice => "Message was not received"
    end
  end

  page_action :send_reminders, :method => :post do
    reminder_service = ReminderService.new
    count = reminder_service.send_reminders
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

  page_action :generate_quote, method: :post do
    customer_name = params["quote"]["customer_name"]
    customer_id = params["quote"]["id"]
    email = params["quote"]["email_address"]
    code = params["quote"]["sales_agent_code"]
    yop = params["quote"]["year_of_purchase"].to_i
    payment_option = params["payment_option"]
    phone_number = params["quote"]["phone_number"]
    device_id = params["quote"]["device"]["0"]["id"]

    device = Device.find(device_id)

    iv = device.get_insurance_value(code, yop)
    # iv = device.get_insurance_value_by_month_and_year(code, mop, yop)
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

    # puts "Premium Value => #{premium_value}, Premium Type => #{premium_type}"

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

    
    gateway = SMSGateway.new
    gateway.send(phone_number, "#{device.marketing_name}, Year #{yop}. Insurance Value is #{ActionController::Base.helpers.number_to_currency(iv, :unit => 'KES ', :precision => 0, :delimiter => '')}. Payment due is #{ActionController::Base.helpers.number_to_currency(annual_premium, :unit => 'KES ', :precision => 0, :delimiter => '')}")
    gateway.send(phone_number, "Please pay via MPesa (Business No. #{ENV['MPESA']}) or Airtel Money (Business Name #{ENV['AIRTEL']}). Your account no. #{account_name} is valid till #{q.expiry_date.utc.to_s(:full)}.")

    redirect_to admin_simulator_path, :notice => "#{customer_name}, #{iv}"
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
      end
    end

    columns  do
      reminder_service = ReminderService.new
      column do        
        today = reminder_service.get_policies_expiring_in_duration(0)
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
        today = reminder_service.get_policies_expiring_in_duration(2)
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
        policies = Policy.where("expiry < ?", ReminderService._get_start_of_day(Time.now))
        table_for policies, :class=> "index_table" do |p|
          column "Customer" do |p|
            p.customer.name if !p.customer.nil?
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
        end 
        render "update"
      end
    end
  end

end
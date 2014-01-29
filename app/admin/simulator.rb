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
        render "update"
      end
    end
  end

end
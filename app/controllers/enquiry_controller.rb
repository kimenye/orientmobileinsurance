require 'premium_service'
require 'deviceatlasapi'

class EnquiryController < Wicked::WizardController
  include DeviceAtlasApi::ControllerHelpers
  include ActionView::Helpers::NumberHelper
  layout "mobile"

  skip_before_filter :verify_authenticity_token
  steps :begin, :enter_sales_info, :not_insurable, :confirm_device, :personal_details, :serial_claimants, :confirm_personal_details, :complete_enquiry

  def show
    begin
      @enquiry = Enquiry.find(session[:enquiry_id])
      case step
        when :complete_enquiry
          smsMessage = session[:sms_message]
          @gateway = SMSGateway.new

          smsMessage.each do |message|
            @gateway.send(session[:sms_to], message)
          end
      end
      render_wizard
    rescue => error
      puts "Error occured #{error}"
      redirect_to start_again_path
    end
  end

  def start_again

  end

  def payment_notification
    puts ">>>> #{params}"
    channel = params[:JP_CHANNEL]

    account_id = params[:JP_MERCHANT_ORDERID]
    if channel == "MPESA" || channel == "AIRTEL"
      account_id = params[:JP_ITEM_NAME]
    end

    amount = params[:JP_AMOUNT]
    transaction_ref = params[:JP_TRANID]

    service = PaymentService.new

    result = service.handle_payment(account_id, amount, transaction_ref, channel)

    if result
      @message = "Thank you for your payment of #{number_to_currency(amount, :unit => "KES ", :precision => 0, :delimiter => "")}"
      if channel == "MPESA" || channel == "AIRTEL"
        puts ">>> Render OK #{channel}"
        render text: "OK"
      end
    else
      puts ">> Don't know this account number #{account_id}"
      render text: "OK"
    end
  end

  def update
    @enquiry = Enquiry.find(session[:enquiry_id])
    premium_service = PremiumService.new
    case step
      when :enter_sales_info
        code = params[:enquiry][:sales_agent_code].upcase if !params[:enquiry][:sales_agent_code].nil?
        agent = Agent.find_by_code(code)
        if !agent.nil?
          @enquiry.agent_id = agent.id
        end
        @enquiry.update_attributes(params[:enquiry])
        
        if @enquiry.valid?
          code = agent.code if !agent.nil?
          if !@enquiry.year_of_purchase.nil?
            is_insurable = premium_service.is_insurable @enquiry.year_of_purchase
          else
            is_insurable = false
          end

          device_data = get_device_data
          session[:device] = device_data
          #Check for the devices among our supported devices
          model = device_data["model"]
          vendor = device_data["vendor"]
          marketingName = device_data["marketingName"]

          invalid_da = (vendor.nil? || vendor.empty?) && (model.nil? || model.empty?)
          puts ">> Invalid match from device atlas : #{invalid_da}"

          @enquiry.model = model
          @enquiry.vendor = vendor
          @enquiry.marketing_name = marketingName

          iphone_5 = request.cookies["device.isPhone5"]
          puts "Reporting #{model}, #{vendor}, #{marketingName} - #{iphone_5}"
          if iphone_5 == "true"
            model = "IPHONE 5"
          end

          puts ">> Searching for #{model}, #{vendor}, #{marketingName}"

          device = nil

          if !invalid_da
            device = Device.device_similar_to(vendor, model, Device.get_marketing_search_parameter(marketingName)).first

            puts ">> Device is nil ? #{device.nil?}"

            if device.nil?
              device = Device.wider_search(model).first
            end
          end

          puts ">> After device is nil ? #{device.nil?}"

          @enquiry.detected_device_id= device.id if ! device.nil?
          @enquiry.detected = !device.nil?
          @enquiry.save!

          if device.nil? || is_insurable == false
            jump_to :not_insurable
          else
            session[:device] = device
            iv = device.get_insurance_value(code, @enquiry.year_of_purchase)
            details = {
              "insurance_value" => number_to_currency(iv, :unit => "KES ", :precision => 0, :delimiter => ""),
              "insurance_value_uf" => iv,
              "annual_premium" => number_to_currency(premium_service.calculate_annual_premium(code, iv), :unit => "KES ", :precision => 0, :delimiter => ""),
              "annual_premium_uf" => premium_service.calculate_annual_premium(code, iv),
              "quarterly_premium" => number_to_currency(premium_service.calculate_monthly_premium(code, iv), :unit => "KES ", :precision => 0, :delimiter => ""),
              "quarterly_premium_uf" => premium_service.calculate_monthly_premium(code, iv),
              "sales_agent" => ("#{agent.brand} #{agent.outlet_name}" if !agent.nil?)
            }

            session[:quote_details] = details

            customer = Customer.find_by_id_passport(params[:enquiry][:customer_id])
            if(customer.nil?)
              customer = Customer.create!(:name => params[:enquiry][:customer_name], :id_passport => params[:enquiry][:customer_id], :email => params[:enquiry][:customer_email], :phone_number => @enquiry.phone_number)
            end

            account_name = "OMB#{premium_service.generate_unique_account_number}"

            user_details = {
                "customer_name" => @enquiry.customer_name,
                "customer_id" => @enquiry.customer_id,
                "customer_email" => @enquiry.customer_email,
                "customer_phone_number" => @enquiry.phone_number,
                "account_name" => account_name
            }

            session[:user_details] = user_details

            claim_service = ClaimService.new

            if(claim_service.is_serial_claimant(params[:enquiry][:customer_id]))
              jump_to :serial_claimants
            end

            insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => session[:device].id, :yop => @enquiry.year_of_purchase, :phone_number => @enquiry.phone_number
            q = Quote.create!(:account_name => account_name, :annual_premium => session[:quote_details]["annual_premium_uf"],
                              :expiry_date => 72.hours.from_now, :monthly_premium => session[:quote_details]["quarterly_premium_uf"],
                              :insured_device_id => insured_device.id, :premium_type => session[:user_details]["customer_payment_option"],
                              :insured_value => session[:quote_details]["insurance_value_uf"],
                              :agent_id => @enquiry.agent_id)

            @gateway = SMSGateway.new

            session[:quote] = q

            jump_to :confirm_personal_details
          end
        end
      when :confirm_personal_details
        @enquiry.update_attributes(params[:enquiry])

        if @enquiry.customer_payment_option == "Annual"
          due = session[:quote_details]["annual_premium"]
          session[:quote_details]["due"] = session[:quote_details]["annual_premium_uf"]
        elsif(@enquiry.customer_payment_option == 'Monthly')
          due = session[:quote_details]["quarterly_premium"]
          session[:quote_details]["due"] = session[:quote_details]["quarterly_premium_uf"]
        end

        q = Quote.find_by_account_name(session[:user_details]["account_name"])
        if !q.nil?
          q.premium_type = @enquiry.customer_payment_option
          q.save!
        end

        #smsMessage = ["#{session[:device].marketing_name}, Year #{@enquiry.year_of_purchase}. Insurance Value is #{session[:quote_details]["insurance_value"]}. Payment due is #{due}.","Please pay via MPesa (Business No. #{ENV['MPESA']}) or Airtel Money (Business Name #{ENV['AIRTEL']}). Your account no. #{session[:user_details]["account_name"]} is valid till #{session[:quote].expiry_date.in_time_zone(ENV['TZ']).to_s(:full)}."]
        smsMessage = ["#{session[:device].marketing_name}, Year #{@enquiry.year_of_purchase}. Insurance Value is #{session[:quote_details]["insurance_value"]}. Payment due is #{due}.","Please pay via MPesa (Business No. #{ENV['MPESA']}) or Airtel Money (Business Name #{ENV['AIRTEL']}). Your account no. #{session[:user_details]["account_name"]} is valid till #{session[:quote].expiry_date.utc.to_s(:full)}."]
        session[:sms_message] = smsMessage
        session[:sms_to] = @enquiry.phone_number
    end
    render_wizard @enquiry
  end

  def destroy
    @enquiry = Enquiry.find(params[:id])
    @enquiry.destroy
    redirect_to enquiries_path, :notice => "Enquiry deleted."
  end

  def create
    @enquiry = Enquiry.new
    @enquiry.attributes = params[:enquiry]
    @enquiry.save
    redirect_to enquiries_path, :notice => "Enquiry created"
  end
end
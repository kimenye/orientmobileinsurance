require 'premium_service'
require 'deviceatlasapi'
#require 'pry'

class EnquiryController < Wicked::WizardController
  include DeviceAtlasApi::ControllerHelpers
  include ActionView::Helpers::NumberHelper
  layout "mobile"

  steps :begin, :enter_sales_info, :not_insurable, :confirm_device, :personal_details, :serial_claimants, :confirm_personal_details, :complete_enquiry

  def show
    @enquiry = Enquiry.find(session[:enquiry_id])
    render_wizard
  end

  def payment_notification
    #=> {"JP_TRANID"=>"599038",
    #    "JP_MERCHANT_ORDERID"=>"TDXBLF",
    #    "JP_ITEM_NAME"=>"OMB Insurance",
    #    "JP_AMOUNT"=>"1727.00",
    #    "JP_CURRENCY"=>"KES",
    #    "JP_TIMESTAMP"=>"20130731164630",
    #    "JP_PASSWORD"=>"90e096f9ac2acaddb26ec89aef8c129f",
    #    "JP_CHANNEL"=>"VISA",
    #    "action"=>"payment_notification",
    #    "controller"=>"enquiry"}

    puts ">>>> #{params}"

    quote = Quote.find_by_account_name params[:JP_MERCHANT_ORDERID]
    service = PremiumService.new
    sms = SMSGateway.new
    if !quote.nil?
      if quote.policy.nil?
        customer = quote.insured_device.customer
        policy = Policy.create! :quote_id => quote.id, :policy_number => service.generate_unique_policy_number, :status => "Inactive"
        payment = Payment.create! :policy_id => policy.id, :amount => params[:JP_AMOUNT], :method => "JP", :reference => params[:JP_TRANID]

        @message = "Thank you for your payment of #{number_to_currency(params[:JP_AMOUNT], :unit => "KES ", :precision => 0)}"

        if quote.insured_device.imei.nil?
          sms.send customer.phone_number, "Dial *#06# to retrieve the 15-digit IMEI no. of your device. Record this it and SMS the word OMI and the number to #{ENV['SHORT_CODE']} to receive your Orient Mobile policy confirmation."
        end
      end
    else
      @message = "No payment was received"
    end
  end

  def update
    @enquiry = Enquiry.find(session[:enquiry_id])
    premium_service = PremiumService.new
    case step
      when :enter_sales_info
        agent = Agent.find_by_code(params[:enquiry][:sales_agent_code])
        if !agent.nil?
          @enquiry.agent_id = agent.id
        end
        @enquiry.update_attributes(params[:enquiry])

        code = agent.code if !agent.nil?
        if !@enquiry.year_of_purchase.nil?
          is_insurable = premium_service.is_insurable(@enquiry.year_of_purchase, code)
        else
          is_insurable = false
        end

        device_data = get_device_data
        session[:device] = device_data
        #Check for the devices among our supported devices
        model = device_data["model"]
        vendor = device_data["vendor"]
        marketingName = device_data["marketingName"]

        device = Device.device_similar_to(vendor, model, Device.get_marketing_search_parameter(marketingName)).first

        if device.nil? || is_insurable == false
          jump_to :not_insurable
        else
          session[:device] = device
          iv = device.get_insurance_value(code, @enquiry.year_of_purchase)
          details = {
            "insurance_value" => number_to_currency(iv, :unit => "KES ", :precision => 0),
            "insurance_value_uf" => iv,
            "annual_premium" => number_to_currency(premium_service.calculate_annual_premium(code, iv), :unit => "KES ", :precision => 0),
            "annual_premium_uf" => premium_service.calculate_annual_premium(code, iv),
            "quarterly_premium" => number_to_currency(premium_service.calculate_monthly_premium(code, iv), :unit => "KES ", :precision => 0),
            "quarterly_premium_uf" => premium_service.calculate_monthly_premium(code, iv),
            "sales_agent" => ("#{agent.brand} #{agent.outlet_name}" if !agent.nil?)
          }

          session[:quote_details] = details
          jump_to :confirm_device
          #jump_to :personal_details
        end
      when :confirm_device
        #do nothing
      when :personal_details
        customer = Customer.find_by_id_passport(params[:enquiry][:customer_id])
        if(customer.nil?)
          customer = Customer.create!(:name => params[:enquiry][:customer_name], :id_passport => params[:enquiry][:customer_id], :email => params[:enquiry][:customer_email], :phone_number => params[:enquiry][:customer_phone_number])
        end


        @enquiry.update_attributes(params[:enquiry])

        account_name = "ORI#{premium_service.generate_unique_account_number}"

        user_details = {
            "customer_name" => @enquiry.customer_name,
            "customer_id" => @enquiry.customer_id,
            "customer_email" => @enquiry.customer_email,
            "customer_phone_number" => @enquiry.customer_phone_number,
            "customer_payment_option" => @enquiry.customer_payment_option,
            "account_name" => account_name
        }

        session[:user_details] = user_details

        claim_service = ClaimService.new

        if(claim_service.is_serial_claimant(params[:enquiry][:customer_id]))
          jump_to :serial_claimants
        end

        insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => session[:device].id
        q = Quote.create!(:account_name => account_name, :annual_premium => session[:quote_details]["annual_premium_uf"],
                          :expiry_date => 72.hours.from_now, :monthly_premium => session[:quote_details]["quarterly_premium_uf"],
                          :insured_device_id => insured_device.id, :premium_type => session[:user_details]["customer_payment_option"],
                          :insured_value => session[:quote_details]["insurance_value_uf"])

        @gateway = SMSGateway.new

        if(session[:user_details]["customer_payment_option"] == 'Annual')
            due = session[:quote_details]["annual_premium"]
        elsif(session[:user_details]["customer_payment_option"] == 'Monthly')
            due = session[:quote_details]["quarterly_premium"]
        end
        session[:quote] = q

        smsMessage = "#{session[:device].marketing_name} Year: #{@enquiry.year_of_purchase} Insurance Value: #{session[:quote_details]["insurance_value"]} Payment due: #{number_to_currency(due, :unit => 'KES ', :precision => 0, :separator => "")} Please pay via MPesa (Business No. #{ENV['MPESA']}) or Airtel Money (Business Name JAMBOPAY). Your acc no #{session[:user_details]["account_name"]} is valid until #{q.expiry_date.in_time_zone(ENV['TZ']).to_s(:full)}"
        @gateway.send(@enquiry.customer_phone_number, smsMessage)

        jump_to :confirm_personal_details

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
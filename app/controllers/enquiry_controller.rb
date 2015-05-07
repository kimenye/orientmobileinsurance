require 'premium_service'
require 'deviceatlas_cloud_client'

class EnquiryController < Wicked::WizardController
  include DeviceAtlasCloudClient::ControllerHelper
  include ActionView::Helpers::NumberHelper
  layout "mobile"

  skip_before_filter :verify_authenticity_token
  steps :begin, :insure, :device_details, :enter_sales_info, :not_insurable, :confirm_device, :personal_details, :serial_claimants, :confirm_personal_details, :complete_enquiry

  def corporate_payment
    render 'corporate_payment', :layout => "application"
  end

  def corporate_payment_form
    @bp = BulkPayment.find_by_code(params[:code])
    if @bp.nil?
      redirect_to corporate_payment_path, :layout => "application", :notice => "No account with the code #{params[:code]} exists"
    else
      @bp.email = params[:email]
      @bp.phone_number = params[:phone_number]
      @bp.save!

      render 'corporate_payment_form', :layout => "application"
    end    
  end

  def corporate_receipt
    @bp = BulkPayment.find_by_code(params[:JP_MERCHANT_ORDERID])
    amount = params[:JP_AMOUNT]
    if @bp.reference != params[:JP_TRANID]
      @bp.amount_paid = 0 if @bp.amount_paid.nil?
      @bp.amount_paid += amount.to_f
      @bp.reference = params[:JP_TRANID]
      @bp.save!
    end

    render 'corporate_receipt', :layout => "application"
  end

  def airtel
    agent = Agent.find_by_code(ENV['AIRTEL_CODE'])
    @enquiry = Enquiry.create!({ source: 'USSD', enquiry_type: 'Airtel', agent_id: agent.id, sales_agent_code: agent.code })
  
    session[:enquiry_id] = @enquiry.id
    redirect_to enquiry_index_path
  end

  def show
    begin
      # find the enquiry that's saved on the session.
      if Enquiry.find_by_id(session[:enquiry_id]).nil? || session[:enquiry_id].nil?        
        code = nil
        if params.has_key? "q"
          a = Agent.find_by_tag params[:q]
          code = a.code if !a.nil?
        end
        @enquiry = Enquiry.create!(:source => "DIRECT", :sales_agent_code => code)
        
        session[:enquiry_id] = @enquiry.id
      else
        @enquiry = Enquiry.find_by_id(session[:enquiry_id])
      end

      device_data = get_device_data
      
      session[:device_marketing_name] = device_data[:marketingName]
      session[:model] = device_data[:model]      
      
      model = device_data[:model].downcase
      vendor = device_data[:vendor]

      session[:device_model] = model
      session[:apple] = false

      if model.starts_with?("iphone") || model.starts_with?("ipad")
        session[:apple] = true

        if model.starts_with?("iphone 6")
          possible_devices = Device.model_search(vendor, model)
          session[:possible_models] = possible_devices
        else
          possible_devices = Device.model_like_search(vendor, model)
          session[:possible_models] = possible_devices
        end
      end

      render_wizard
    rescue => error
      logger.error "Error #{error.backtrace}"
      Rollbar.error(error, :phone_number => @enquiry.phone_number)
      session[:enquiry] = nil
      redirect_to start_again_path
    end
  end

  def start_again
  end

  def start_wizard
    @enquiry = Enquiry.find_by_id(session[:enquiry_id])
    if session[:apple]
      if session[:possible_models].count == 0
        redirect_to wizard_path(:not_insurable)
      else
        redirect_to wizard_path(:device_details)
      end
    else
      redirect_to wizard_path(:device_details)
    end
  end

  def insure
    if params.has_key? "q"
      redirect_to "/enquiry/insure?q=#{params[:q]}"
    else 
      redirect_to "/enquiry/insure" 
    end
  end

  def payment_notification
    service = PaymentService.new
    channel = params[:JP_CHANNEL]

    account_id = params[:JP_MERCHANT_ORDERID]
    if channel == "MPESA" || channel == "AIRTEL"
      account_id = params[:JP_ITEM_NAME]
    end

    amount = params[:JP_AMOUNT]
    transaction_ref = params[:JP_TRANID]

    result = service.handle_payment(account_id, amount, transaction_ref, channel)
    @message = "Thank you for your payment of #{number_to_currency(amount, :unit => "KES ", :precision => 0, :delimiter => "")}"

    if result
      if channel == "MPESA" || channel == "AIRTEL"
        render text: "OK"
      end
    else
      render text: "OK"
    end
  end

  def update
    @enquiry = Enquiry.find(session[:enquiry_id])
    premium_service = PremiumService.new

    case step
      when :device_details
        code = params[:enquiry][:sales_agent_code].upcase if !params[:enquiry][:sales_agent_code].nil?
        agent = Agent.find_by_code(code)
        if !agent.nil?
          @enquiry.agent_id = agent.id
        end
        @enquiry.update_attributes(params[:enquiry])
        
        if @enquiry.valid?
          code = agent.code if !agent.nil?
          if !@enquiry.year_of_purchase.nil?
            is_insurable = premium_service.is_insurable_by_month_and_year(@enquiry.month_of_purchase, @enquiry.year_of_purchase)
          else
            is_insurable = false
          end

          device_data = get_device_data          
          session[:device] = device_data          

          device = nil
          model_id = params[:enquiry][:model]
          if model_id
            device = Device.find(model_id)
            model = device.model
          end
          vendor = device_data[:vendor]
          marketingName = device_data[:marketingName]
          model = device_data[:model]

          invalid_da = (vendor.nil? || vendor.empty?) && (model.nil? || model.empty?)
          logger.debug "Invalid match from device atlas : #{invalid_da}"

          @enquiry.model = model
          @enquiry.vendor = vendor
          @enquiry.marketing_name = marketingName

          logger.debug "Searching for #{model}, #{vendor}, #{marketingName}"          

          if !invalid_da && device.nil?
            device = Device.model_search(vendor, model).first
          end

          logger.debug "After device is nil ? #{device.nil?}"
          @enquiry.user_agent = request.env['HTTP_USER_AGENT']
          @enquiry.detected_device_id= device.id if ! device.nil?
          @enquiry.detected = !device.nil?
          @enquiry.save!

          if device.nil? || is_insurable == false
            logger.debug "Device is nil"
            jump_to :not_insurable
          else
            session[:device] = device
            # iv = device.get_insurance_value(code, @enquiry.year_of_purchase)
            iv = device.get_insurance_value_by_month_and_year(code, @enquiry.month_of_purchase, @enquiry.year_of_purchase)
            annual_premium = premium_service.calculate_annual_premium(code, iv, @enquiry.year_of_purchase)
            installment_premium = premium_service.calculate_monthly_premium(code, iv, @enquiry.year_of_purchase)
            six_monthly_premium = premium_service.calculate_monthly_premium(code, iv, @enquiry.year_of_purchase, 6)
            details = {
              "insurance_value" => number_to_currency(iv, :unit => "KES ", :precision => 0, :delimiter => ""),
              "insurance_value_uf" => iv,
              "annual_premium" => number_to_currency(annual_premium, :unit => "KES ", :precision => 0, :delimiter => ""),
              "annual_premium_uf" => annual_premium,
              "quarterly_premium" => number_to_currency(installment_premium, :unit => "KES ", :precision => 0, :delimiter => ""),
              "quarterly_premium_uf" => installment_premium,
              "six_monthly_premium" => number_to_currency(six_monthly_premium, :unit => "KES ", :precision => 0, :delimiter => ""),
              "six_monthly_premium_uf" => six_monthly_premium,
              "sales_agent" => ("#{agent.brand} #{agent.outlet_name}" if !agent.nil?)
            }

            session[:quote_details] = details
            jump_to :enter_sales_info
          end
          
        end
      when :enter_sales_info
        if @enquiry.valid?
          @enquiry.phone_number = (params[:enquiry][:phone_number].starts_with? "+") ? params[:enquiry][:phone_number] : "+#{params[:enquiry][:phone_number]}"
          @enquiry.save!
          customer = Customer.find_by_id_passport(params[:enquiry][:customer_id])
          if(customer.nil?)
            customer = Customer.create!(:name => params[:enquiry][:customer_name], :id_passport => params[:enquiry][:customer_id], :email => params[:enquiry][:customer_email], :phone_number => @enquiry.phone_number)
          end

          @enquiry.update_attributes(params[:enquiry])
          session[:quote_details]["due"] = @enquiry.customer_payment_option == "Annual"? session[:quote_details]["annual_premium"] : session[:quote_details]["quarterly_premium"]

          account_name = "OMB#{premium_service.generate_unique_account_number}"

          user_details = {
              "customer_name" => params[:enquiry][:customer_name],
              "customer_id" => params[:enquiry][:customer_id],
              "customer_email" => params[:enquiry][:customer_email],
              "customer_phone_number" => @enquiry.phone_number,
              "account_name" => account_name
          }

          session[:user_details] = user_details

          claim_service = ClaimService.new

          if(claim_service.is_serial_claimant(params[:enquiry][:customer_id]))
            jump_to :serial_claimants
          end

          insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => session[:device].id, :yop => @enquiry.year_of_purchase, :phone_number => @enquiry.phone_number, :insurance_value => session[:quote_details]["insurance_value_uf"]
          q = Quote.create!(:account_name => account_name, :annual_premium => session[:quote_details]["annual_premium_uf"],
                            :expiry_date => 336.hours.from_now, :monthly_premium => (params[:enquiry]["customer_payment_option"] == "Monthly"? session[:quote_details]["quarterly_premium_uf"] : session[:quote_details]["six_monthly_premium_uf"]),
                            :insured_device_id => insured_device.id, :premium_type => params[:enquiry]["customer_payment_option"],
                            :insured_value => session[:quote_details]["insurance_value_uf"],
                            :agent_id => @enquiry.agent_id, :customer_id => customer.id, :quote_type => "Individual")

          session[:quote] = q

          jump_to :confirm_personal_details
        end
      when :confirm_personal_details
        smsMessage = ["#{session[:device].marketing_name}, Year #{@enquiry.year_of_purchase}. Insurance Value is #{session[:quote_details]["insurance_value"]}. Payment due is #{session[:quote_details]["due"]}.",
          SmsService.payment_instructions(session[:user_details]["account_name"], session[:quote].expiry_date, @enquiry.enquiry_type)]                

        smsMessage.each do |message|
          SMSGateway.send(@enquiry.phone_number, message)
        end
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
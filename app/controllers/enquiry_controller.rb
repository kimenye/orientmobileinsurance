require 'premium_service'
require 'deviceatlasapi'
#require 'pry'

class EnquiryController < Wicked::WizardController
  include DeviceAtlasApi::ControllerHelpers
  layout "mobile"

  steps :begin, :enter_sales_info, :not_insurable, :confirm_device, :personal_details, :serial_claimants, :confirm_personal_details, :complete_enquiry

  def show
    @enquiry = Enquiry.find(session[:enquiry_id])
    render_wizard
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
            "insurance_value" => iv,
            "annual_premium" => premium_service.calculate_annual_premium(code, iv),
            "quarterly_premium" => premium_service.calculate_monthly_premium(code, iv),
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
          customer = Customer.create!(:name => params[:enquiry][:customer_name], :id_passport => params[:enquiry][:customer_id], :email => params[:enquiry][:customer_email])
        end

        claim_service = ClaimService.new

        if(claim_service.is_serial_claimant(params[:enquiry][:customer_id]))
          jump_to :serial_claimants
        end


        @enquiry.update_attributes(params[:enquiry])

        account_name = premium_service.generate_unique_account_number

        user_details = {
            "customer_name" => @enquiry.customer_name,
            "customer_id" => @enquiry.customer_id,
            "customer_email" => @enquiry.customer_email,
            "customer_payment_option" => @enquiry.customer_payment_option,
            "account_name" => account_name
        }

        session[:user_details] = user_details
        #TODO: include the insured value in the quote
        Quote.create!(:account_name => account_name, :annual_premium => session[:quote_details]["annual_premium"], :expiry_date => "", :monthly_premium => session[:quote_details]["quarterly_premium"], :insured_device_id => "", :premium_type => session[:user_details]["customer_payment_option"])

        # Check if customer is a serial claimant
        #binding.pry

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
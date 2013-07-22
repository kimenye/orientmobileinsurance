require 'premium_service'
require 'deviceatlasapi'

class EnquiryController < Wicked::WizardController
  include DeviceAtlasApi::ControllerHelpers
  layout "mobile"

  steps :begin, :enter_sales_info, :not_insurable, :confirm_device, :personal_details, :serial_claimants

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

        device = Device.device_similar_to(device_data["model"]) .first

        if device.nil? || is_insurable == false
          jump_to :not_insurable
        end

        if is_insurable
          jump_to :confirm_device
          #jump_to :personal_details
        end
      when :personal_details
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

  def secure

  end

  def status_check

    @service = PremiumService.new

    @year_of_purchase = params[:year_of_purchase]

    @sales_agent_code = params[:sales_agent_code]

    @agent = Agent.find_by_code(@sales_agent_code)

    @is_insurable = @service.is_insurable(@year_of_purchase, @sales_agent_code)

    @device_info = get_device_data

    render 'status'
  end

end

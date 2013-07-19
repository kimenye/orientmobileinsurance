require 'premium_service'
require 'deviceatlasapi'

class EnquiryController < Wicked::WizardController
  include DeviceAtlasApi::ControllerHelpers
  layout "mobile"

  steps :begin, :enter_sales_info, :not_insurable

  def show
    @enquiry = Enquiry.find(session[:enquiry_id])
    render_wizard
  end

  def update
    @enquiry = Enquiry.find(session[:enquiry_id])
    case step
      when :enter_sales_info
        agent = Agent.find_by_code(params[:sales_agent_code])
        if !agent.nil?
          @enquiry.agent_id = agent.id
        end
        @enquiry.update_attributes(params[:enquiry])
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

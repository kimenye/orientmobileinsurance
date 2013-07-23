class StatusController < ApplicationController
  include Wicked::Wizard
  layout "mobile"

  steps :customer_id, :customer_not_found, :select_device

  def show
    @status = Status.new
    session[:status] = @status
    render_wizard
  end

  def update
    @status = session[:status]
    @status.update_attributes(params[:status])

    case step
      when :customer_id
        customer = Customer.find_by_id_passport(@status.customer_id)
        if customer.nil?
          jump_to :customer_not_found
        else
          session[:devices] = customer.insured_devices
          jump_to :select_device
        end
      when :select_device
        if @status.enquiry_type == "Policy Status"
          quote = Quote.find_by_insured_device_id @status.insured_device_id
          policy = Policy.find_by_quote_id quote.id
          session[:policy] = policy

          jump_to :policy_status
        end
    end

    #update the session object
    session[:status] = @status
    render_wizard
  end

end
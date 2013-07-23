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
    end
    render_wizard
  end

end
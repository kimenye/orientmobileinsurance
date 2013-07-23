class StatusController < ApplicationController
  include Wicked::Wizard
  layout "mobile"

  steps :customer_id, :customer_not_found

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
        end
    end
    render_wizard
  end

end
class StatusController < ApplicationController
  include Wicked::Wizard
  layout "mobile"

  steps :customer_id, :customer_not_found, :claim_select_device, :select_device, :claim_type

  def show
    @status = session[:status]
    render_wizard
  end

  def update
    @status = session[:status]

    @status.update_attributes(params[:status])

    @customer = Customer.find_by_id_passport(@status.customer_id)
    case step
      when :customer_id
        if @customer.nil?
          jump_to :customer_not_found
        else
          session[:devices] = @customer.insured_devices
          if @status.action == "new-claim"
            @status.contact_tel_no = @customer.phone_number
            jump_to :claim_select_device
          else
            jump_to :select_device
          end
        end
      when :select_device
        if @status.enquiry_type == "Policy Status"
          quote = Quote.find_by_insured_device_id @status.insured_device_id
          policy = Policy.find_by_quote_id quote.id
          session[:policy] = policy

          jump_to :policy_status
        end
      when :claim_select_device
        quote = Quote.find_by_insured_device_id @status.insured_device_id
        policy = Policy.find_by_quote_id quote.id
        session[:policy] = policy
        towns = Agent.select("distinct town").collect { |t| t.town.strip }
        session[:towns] = towns

        jump_to :claim_type
      when :claim_type
        policy = session[:policy]
        service = ClaimService.new
        claim = Claim.create! :policy_id => policy.id, :claim_type => @status.claim_type, :contact_number => @status.contact_number, :claim_no => service.create_claim_no


        if @status.claim_type == "Loss / Theft"

        end


    end

    #update the session object
    session[:customer] = @customer
    session[:status] = @status
    render_wizard
  end

end
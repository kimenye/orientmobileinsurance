class StatusController < ApplicationController
  include ActionView::Helpers::NumberHelper
  include Wicked::Wizard
  layout "mobile"

  steps :customer_id, :customer_not_found, :claim_select_device, :select_device, :cannot_claim, :claim_type

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
        elsif @status.enquiry_type == "Claim Status"
          quote = Quote.find_by_insured_device_id @status.insured_device_id
          policy = quote.policy
          session[:policy] = policy
          if policy.has_claim?
            claim = Claim.find_by_policy_id(policy.id)
            session[:claim] = claim
          end
          jump_to :claim_status
        end
      when :claim_select_device
        quote = Quote.find_by_insured_device_id @status.insured_device_id
        policy = quote.policy
        premium_service = PremiumService.new
        if !policy.nil?
          session[:policy] = policy
        else
          session[:status_message] = premium_service.get_status_message quote
        end

        if !policy.nil? && policy.is_active?
          towns = Agent.select("distinct town").collect { |t| t.town.strip if !t.town.nil? }
          towns = towns.reject{ |t| t.nil? }
          session[:towns] = towns

          jump_to :claim_type
        else
          jump_to :cannot_claim
        end
      when :claim_type
        policy = session[:policy]
        service = ClaimService.new
        claim = Claim.create! :policy_id => policy.id, :claim_type => @status.claim_type, :contact_number => @customer.phone_number, :claim_no => service.create_claim_no, :nearest_town => @status.nearest_town
        towns = Agent.select("distinct town").collect { |t| t.town.strip if !t.town.nil? }
        session[:towns] = towns

        if @status.claim_type == "Loss / Theft"

        end
        brand = service.find_brands_in_town(@status.nearest_town)
        session[:brand] = brand
        session[:claim] = claim

        #Send sms
        @gateway = SMSGateway.new
        smsMessage = "Ref No: #{claim.claim_no}. Please visit #{brand.brand_1} in #{@status.nearest_town} with the damaged device, purchase receipt or warranty, and original ID or passport."
        @gateway.send(@customer.phone_number, smsMessage)

        session[:id] = @customer.id
        jump_to :claim_centers


    end

    #update the session object
    session[:customer] = @customer
    session[:status] = @status
    render_wizard
  end

end
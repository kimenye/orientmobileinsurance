class PrepaidDevicesController < ApplicationController
  layout 'mobile'
  def customer_details
    insured_device = InsuredDevice.find_by_imei(params["imei"])
    customer = Customer.find_by_hashed_phone_number(params["number"])
    if !insured_device.activated && !customer.nil? && insured_device.customer_id == customer.id
  	 @prepaid_customer = Customer.find_by_hashed_phone_number(params["number"])
    else
      redirect_to prepaid_devices_imei_activated_path
    end
  end

  def confirmation
    @prepaid_customer = Customer.find_by_hashed_phone_number(params["customer"]["phone_number"])
    @prepaid_customer.name = params["customer"]["name"]
    @prepaid_customer.email = params["customer"]["email"]
    @prepaid_customer.id_passport = params["customer"]["id_passport"]
    @prepaid_customer.save!

    quote = Quote.find_by_customer_id(@prepaid_customer.id)    

    insured_device = @prepaid_customer.insured_devices.first
    insured_device.activated = true
    insured_device.save!

    service = PremiumService.new

    policy = Policy.find_by_insured_device_id @prepaid_customer.insured_devices.first.id
    policy.status = "Active"
    policy.start_date = Time.now
    policy.expiry = 365.days.from_now
    policy.quote_id = quote.id
    policy.policy_number = service.generate_unique_policy_number
    policy.save!

  	gateway = SMSGateway.new
  	gateway.send(@prepaid_customer.phone_number, "You have successfully covered your device. Orient Mobile policy #{policy.policy_number} valid till #{policy.expiry.to_s(:simple)}. Policy details: #{ENV['OMB_URL']}")
    CustomerMailer.prepaid_customer(policy).deliver
  end

  def imei_activated
  	
  end
end

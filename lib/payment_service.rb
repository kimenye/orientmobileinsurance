class PaymentService

  include ActionView::Helpers::NumberHelper

  def is_pending_payment? (account_name)
    q = Quote.find_by_account_name(account_name)
    if !q.is_corporate?
      policy = q.policy
      if policy.nil?
        return true
      else
        return policy.is_owing?
      end
    else
      return q.corporate_amount_paid < q.amount_due
    end
  end

  def handle_payment(account_name, amount, transaction_ref, channel)

    quote = Quote.find_by_account_name account_name.upcase
    service = PremiumService.new
    sms = SMSGateway.new
    if !quote.nil?
      
      customer = quote.insured_device.customer if !quote.is_corporate?
      customer = quote.customer if quote.is_corporate?

      if !quote.is_corporate?
        first_payment = quote.policy.nil?
        if quote.policy.nil? 
          policy = Policy.create! :quote_id => quote.id, :policy_number => service.generate_unique_policy_number, :status => "Pending", :insured_device_id => quote.insured_device.id
        end

        policy = quote.policy
        payment = Payment.find_by_reference(transaction_ref)


        if payment.nil?
          payment = Payment.create! :quote_id => quote.id,
                                    :policy_id => policy.id,
                                    :amount => amount, 
                                    :method => channel,
                                    :reference => transaction_ref


          
          quote.premium_type = "Annual" if payment.amount.to_f == quote.annual_premium.to_f && first_payment
          quote.save!
        
          customer.lead = false
          customer.save!


          if quote.insured_device.imei.nil?
            if policy.minimum_paid
              sms.send quote.insured_device.phone_number, "Dial *#06# to retrieve your device IMEI no.  Record the first 15 digits of the IMEI and SMS them to #{ENV['SHORT_CODE']} to receive your Orient Mobile policy confirmation"
            else
              sms.send quote.insured_device.phone_number, "Thank you for your payment. The amount due was #{number_to_currency(quote.minimum_due, :unit => "KES ", :precision => 0, :delimiter => "")}. Please top up with #{number_to_currency(policy.minimum_due, :unit => "KES ", :precision => 0, :delimiter => "")} to proceed."
            end
          else
            service.set_policy_dates policy
            policy.save!
            
            insured_value_str = ActionController::Base.helpers.number_to_currency(policy.quote.insured_value, :unit => "KES ", :precision => 0, :delimiter => "")
            sms.send quote.insured_device.phone_number, "You have successfully covered your device, value #{insured_value_str}. Orient Mobile policy #{policy.policy_number} valid till #{policy.expiry.to_s(:simple)}. Policy details: #{ENV['OMB_URL']}"
            email = CustomerMailer.policy_purchase(policy).deliver
          end

          return true
        else
          return false
        end
      else
        payment = Payment.find_by_reference(transaction_ref)
        if payment.nil?
          payment = Payment.create! :quote_id => quote.id, :amount => amount, :method => channel, :reference => transaction_ref

          if is_pending_payment?(quote.account_name)
            sms.send quote.customer.phone_number, "Thank you for your payment. The amount due was #{number_to_currency(quote.minimum_due, :unit => "KES ", :precision => 0, :delimiter => "")}. Please top up with #{number_to_currency(quote.amount_due - quote.corporate_amount_paid, :unit => "KES ", :precision => 0, :delimiter => "")} to proceed."
            # send an email as well
          else
            # create policies for all the devices
            insured_devices = InsuredDevice.find_all_by_quote_id quote.id
            insured_devices.each do |id|
              p = Policy.create! :quote_id => quote.id, :policy_number => service.generate_unique_policy_number, :status => "Active", :start_date => Time.now, :expiry => 365.days.from_now, :insured_device_id => id.id
            end
            email = CustomerMailer.bulk_policy_purchase(quote).deliver
          end
        else
          return false
        end
      end
    else
      return false
    end
  end
end
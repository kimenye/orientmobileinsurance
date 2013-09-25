class PaymentService

  include ActionView::Helpers::NumberHelper

  def handle_payment(account_name, amount, transaction_ref, channel)


    quote = Quote.find_by_account_name account_name.upcase
    service = PremiumService.new
    sms = SMSGateway.new
    if !quote.nil?
      puts ">> Quote is not nil #{quote}"
      customer = quote.insured_device.customer
      if quote.policy.nil?
        policy = Policy.create! :quote_id => quote.id, :policy_number => service.generate_unique_policy_number, :status => "Pending"
      end

      policy = quote.policy
      payment = Payment.find_by_reference(transaction_ref)


      if payment.nil?
        payment = Payment.create! :policy_id => policy.id, :amount => amount, :method => channel, :reference => transaction_ref
        @message = "Thank you for your payment of #{number_to_currency(amount, :unit => "KES ", :precision => 0, :delimiter => "")}"

        if quote.insured_device.imei.nil?
          if policy.minimum_paid
            sms.send quote.insured_device.phone_number, "Dial *#06# to retrieve your device IMEI no.  Record the first 15 digits of the IMEI and SMS them to #{ENV['SHORT_CODE']} to receive your Orient Mobile policy confirmation"
          else
            sms.send quote.insured_device.phone_number, "Thank you for your payment. The amount due was #{number_to_currency(quote.minimum_due, :unit => "KES ", :precision => 0, :delimiter => "")}. Please top up with #{number_to_currency(policy.minimum_due, :unit => "KES ", :precision => 0, :delimiter => "")} to proceed."
          end
        else
          service.set_policy_dates policy
          policy.save!

          sms_gateway = SMSGateway.new
          insured_value_str = ActionController::Base.helpers.number_to_currency(policy.quote.insured_value, :unit => "KES ", :precision => 0, :delimiter => "")
          sms_gateway.send quote.insured_device.phone_number, "You have successfully covered your device, value #{insured_value_str}. Orient Mobile policy #{policy.policy_number} valid till #{policy.expiry.to_s(:simple)}. Policy details: #{ENV['OMB_URL']}"
          email = CustomerMailer.policy_purchase(policy).deliver
        end
        true
      else
        false
      end
    else
      false
    end
  end
end
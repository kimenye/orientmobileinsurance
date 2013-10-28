class ReminderService

  def send_reminders

    policies_in_two_days = get_policies_expiring_in_duration(2)
    policies_today = get_policies_expiring_in_duration(0)

    sms_gateway = SMSGateway.new

    policies_today.each { |policy|

      if policy.quote.premium_type == 'Monthly'

        if policy.quote.monthly_premium >= policy.pending_amount
          installment = policy.quote.monthly_premium
        else
          installment = policy.pending_amount
        end

        sms_gateway.send policy.quote.insured_device.phone_number, "Dear #{policy.quote.insured_device.customer.name}, your Orient Mobile premium is due today. Total balance #{number_to_currency(policy.pending_amount, :unit => "KES ", :precision => 0, :delimiter => "")}. Payment due #{number_to_currency(installment, :unit => "KES ", :precision => 0, :delimiter => "")}. Your account no. is #{policy.quote.account_name}."
        sms_gateway.send policy.quote.insured_device.phone_number, "Please pay via MPesa (Business No. 530100) or Airtel Money (Business Name JAMBOPAY). Policy lapses at 11:59PM if payment is not made by then."
      end

    }

    policies_in_two_days.each { |policy|

      if policy.quote.premium_type == 'Monthly'
        if policy.quote.monthly_premium >= policy.pending_amount
          installment = policy.quote.monthly_premium
        else
          installment = policy.pending_amount
        end

        sms_gateway.send policy.quote.insured_device.phone_number, "Dear #{policy.quote.insured_device.customer.name}, your Orient Mobile premium is due on #{policy.expiry.to_s(:simple)}. Total balance #{number_to_currency(policy.pending_amount, :unit => "KES ", :precision => 0, :delimiter => "")}. Payment due #{number_to_currency(installment, :unit => "KES ", :precision => 0, :delimiter => "")}."
        sms_gateway.send policy.quote.insured_device.phone_number, "Please pay via MPesa (Business No. 530100) or Airtel Money (Business Name JAMBOPAY). Your account no. is #{policy.quote.account_name}"

      end

    }

  end

  def get_policies_expiring_in_duration (duration, time=Time.now)
    today_start = _get_start_of_day(time)
    today_end = _get_end_of_day(time)
    start_of_day = today_start + (24 * duration * 3600)
    end_of_day = today_end + (24 * duration * 3600)

    Policy.where(:expiry => start_of_day..end_of_day)

  end

  def _get_start_of_day(time)
    Time.local(time.year, time.month, time.day, 0, 0, 0)
  end

  def _get_end_of_day(time)
    Time.local(time.year, time.month, time.day, 23,59,59)
  end

end
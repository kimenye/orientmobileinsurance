class ReminderService

  def send_reminders
    begin
      sms_gateway = SMSGateway.new
      policies_in_two_days = get_policies_expiring_in_duration(2)
      policies_today = get_policies_expiring_in_duration(0)
      Rails.logger.info "Policies expiring in 2 days #{policies_in_two_days.length}"
      Rails.logger.info "Policies expiring today #{policies_today.length}"
      count = 0

      policies_in_two_days.each do |policy|
        if policy.quote.premium_type == 'Annual'
          days_to_expiry = (policy.expiry.to_date - Time.now.to_date).to_i
          sms_gateway.send policy.quote.insured_device.phone_number, "Dear #{policy.quote.insured_device.customer.name}, your Orient Mobile policy is expiring in #{days_to_expiry} #{'day'.pluralize(days_to_expiry)}. To buy a new policy, go to http://omb.korient.co.ke/insure"
          count += 1
        else
          sms_gateway.send policy.quote.insured_device.phone_number, "Dear #{policy.quote.insured_device.customer.name}, your Orient Mobile premium is due on #{policy.expiry.to_s(:simple)}. Total balance #{ActionController::Base.helpers.number_to_currency(policy.pending_amount, :unit => "KES ", :precision => 0, :delimiter => "")}. Payment due #{ActionController::Base.helpers.number_to_currency(policy.amount_due, :unit => "KES ", :precision => 0, :delimiter => "")}."
          sms_gateway.send policy.quote.insured_device.phone_number, "Please pay via MPesa (Business No. 530100) or Airtel Money (Business Name JAMBOPAY). Your account no. is #{policy.quote.account_name}"
          count += 1
        end
      end

      policies_today.each do |policy|
        if policy.quote.premium_type == 'Annual'
          days_to_expiry = (policy.expiry.to_date - Time.now.to_date).to_i
          sms_gateway.send policy.quote.insured_device.phone_number, "Dear #{policy.quote.insured_device.customer.name}, your Orient Mobile policy is expiring in #{days_to_expiry} #{'day'.pluralize(days_to_expiry)}. To buy a new policy, go to http://omb.korient.co.ke/insure"
          sms_gateway.send policy.quote.insured_device.phone_number, "Please pay via MPesa (Business No. 530100) or Airtel Money (Business Name JAMBOPAY). Your account no. is #{policy.quote.account_name}"
          count += 1
        else
          sms_gateway.send policy.quote.insured_device.phone_number, "Dear #{policy.quote.insured_device.customer.name}, your Orient Mobile premium is due today. Total balance #{ActionController::Base.helpers.number_to_currency(policy.pending_amount, :unit => "KES ", :precision => 0, :delimiter => "")}. Payment due #{ActionController::Base.helpers.number_to_currency(policy.amount_due, :unit => "KES ", :precision => 0, :delimiter => "")}. Your account no. is #{policy.quote.account_name}."
          count += 1
        end
      end
      count
    rescue => error
      logger.error "Error when sending reminders #{error}"
    end
  end

  def get_policies_expiring_in_duration (duration, time=Time.now)
    today_start = ReminderService._get_start_of_day(time)
    today_end = ReminderService._get_end_of_day(time)
    start_of_day = today_start + (24 * duration * 3600)
    end_of_day = today_end + (24 * duration * 3600)

    Policy.where(:expiry => start_of_day..end_of_day)

  end

  def self._get_start_of_day(time)
    Time.local(time.year, time.month, time.day, 0, 0, 0)
  end

  def self._get_end_of_day(time)
    Time.local(time.year, time.month, time.day, 23,59,59)
  end
end
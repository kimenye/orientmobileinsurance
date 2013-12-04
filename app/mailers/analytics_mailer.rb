class AnalyticsMailer < ActionMailer::Base
  default from: "analytics@korient.co.ke"

  def daily to
  	begin
  		# mail(:from => "ombclaims@korient.co.ke", :to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMB Claim Registration Details. Claim No. #{@claim.claim_no}", :bcc => ["#{ENV['CLAIM_REGISTRATION_EMAILS']}"])
		attachments.inline['logo_landscape.png'] = File.read("#{Rails.root}/app/assets/images/logo_landscape.png")
		attachments.inline['d-up.jpg'] = File.read("#{Rails.root}/app/assets/images/d-up.jpg")
		attachments.inline['d-down.png'] = File.read("#{Rails.root}/app/assets/images/d-down.png")

		@num_enquiries = Enquiry.count
		@num_policies = Policy.count
		@num_quotes = Quote.count

		@total = 0
		Payment.all.each do |payment|
			@total += payment.amount
		end

		@insured_value = 0
		@pending = 0
		Policy.all.each do |policy|
			@insured_value += policy.quote.insured_value
			@pending += policy.pending_amount
		end

  		mail(:from => "analytics@korient.co.ke", :to => to, :subject => "Orient Mobile Analytics #{Date.today}")	
  	rescue => error
  		logger.info "Error occured #{error}"
  	end
  end

end

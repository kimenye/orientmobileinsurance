class CustomerMailer < ActionMailer::Base

  default :from => "ombclaims@korient.co.ke"

  def claim_registration(claim)
    begin

      @claim = claim
      service = ClaimService.new      
      @nearest_dealers = service.find_nearest_brands(@claim.nearest_town, @claim.is_stl_only)
      attachments.inline['admin_banner_new.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner_new.jpg")
      mail(:from => "ombclaims@korient.co.ke", :to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMB Claim Registration Details. Claim No. #{@claim.claim_no}", :bcc => ["#{ENV['CLAIM_REGISTRATION_EMAILS']}"])
    rescue => exception
      #  Do nothing
      binding.pry
    end
  end

  def policy_purchase(policy)
    begin
      @policy = policy
      attachments.inline['admin_banner_new.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner_new.jpg")
      attachments['omi.pdf'] = File.read("#{Rails.root}/doc/data/Orient Mobile - Policy Terms & Conditions.pdf")
      mail(:from => "mobile@korient.co.ke", :to => "#{@policy.quote.insured_device.customer.name} <#{@policy.quote.insured_device.customer.email}>", :subject => "OMB Policy Purchase. Policy No. #{@policy.policy_number}")
    rescue
    #  Do nothing
    end
  end

  def claim_decline(claim)
    begin
      @claim = claim
      attachments.inline['admin_banner_new.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner_new.jpg")
      mail(:from => "ombclaims@korient.co.ke", :to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMB Claim No. #{@claim.claim_no}")
    rescue
      #  Do nothing
    end
  end

  def reparable_damage_claim(claim)
    begin
      @claim = claim
      service = ClaimService.new
      # @brand = service.find_brands_in_town(@claim.nearest_town)
      @nearest_dealers = service.find_nearest_brands(@claim.nearest_town, @claim.is_stl_only)
      attachments.inline['admin_banner_new.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner_new.jpg")
      mail(:from => "ombclaims@korient.co.ke", :to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMB Claim No. #{@claim.claim_no}", :bcc => ["#{ENV['FONEXPRESS_EMAIL']}"])
    rescue
      #  Do nothing
    end
  end

  def irreparable_damage_claim(claim)
    begin
      @claim = claim
      service = ClaimService.new
      # @brand = service.find_brands_in_town(@claim.nearest_town)
      @nearest_dealers = service.find_nearest_brands(@claim.nearest_town, @claim.is_stl_only)
      attachments.inline['admin_banner_new.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner_new.jpg")
      mail(:from => "ombclaims@korient.co.ke", :to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMB Claim No. #{@claim.claim_no}", :bcc => ["#{ENV['FONEXPRESS_EMAIL']}"])
    rescue
      #  Do nothing
    end
  end

  def loss_theft_claim(claim)
    begin
      @claim = claim
      service = ClaimService.new
      # @brand = service.find_brands_in_town(@claim.nearest_town)
      @nearest_dealers = service.find_nearest_brands(@claim.nearest_town, @claim.is_stl_only)       
      attachments.inline['admin_banner_new.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner_new.jpg")
      mail(:from => "ombclaims@korient.co.ke", :to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMB Claim No. #{@claim.claim_no}", :bcc => ["#{ENV['FONEXPRESS_EMAIL']}"])
    rescue
      #  Do nothing
    end
  end

  def feedback_mailer(feedback)
    begin
      @feedback = feedback
      # mail(:from => "feedback@korient.co.ke", :to => "mobile@korient.co.ke", :subject => "Customer Feedback: #{@feedback.name} #{@feedback.message}")
      mail(:from => "#{ENV['FEEDBACK_FROM_EMAIL']}", :to => "#{ENV['FEEDBACK_TO_EMAIL']}", :subject => "Customer Feedback: #{@feedback.name} #{@feedback.message}")
    rescue
      # Do nothing
    end
  end

end

class CustomerMailer < ActionMailer::Base

  default :from => "robot@omi.co.ke"

  def claim_registration(claim)
    begin
      @claim = claim
      service = ClaimService.new
      @brand = service.find_brands_in_town(@claim.nearest_town)
      attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
      mail(:to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMI Claim Registration Details. Claim No. #{@claim.claim_no}")
    rescue
      #  Do nothing
    end
  end

  def policy_purchase(policy)
    begin
      @policy = policy
      attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
      attachments['omi.pdf'] = File.read("#{Rails.root}/doc/data/Orient Mobile - Policy Terms & Conditions.pdf")
      mail(:to => "#{@policy.quote.insured_device.customer.name} <#{@policy.quote.insured_device.customer.email}>", :subject => "OMI Policy Purchase. Policy No. #{@policy.policy_number}")
    rescue
    #  Do nothing
    end
  end

  def claim_decline(claim)
    begin
      @claim = claim
      attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
      mail(:to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMI Claim No. #{@claim.claim_no}")
    rescue
      #  Do nothing
    end
  end

  def reparable_damage_claim(claim)
    begin
      @claim = claim
      service = ClaimService.new
      @brand = service.find_brands_in_town(@claim.nearest_town)
      attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
      mail(:to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMI Claim No. #{@claim.claim_no}")
    rescue
      #  Do nothing
    end
  end

  def irreparable_damage_claim(claim)
    begin
      @claim = claim
      service = ClaimService.new
      @brand = service.find_brands_in_town(@claim.nearest_town)
      attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
      mail(:to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMI Claim No. #{@claim.claim_no}")
    rescue
      #  Do nothing
    end
  end

  def loss_theft_claim(claim)

    @claim = claim
    service = ClaimService.new
    @brand = service.find_brands_in_town(@claim.nearest_town)
    attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
    mail(:to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMI Claim No. #{@claim.claim_no}")


    #begin
    #  @claim = claim
    #  service = ClaimService.new
    #  @brand = service.find_brands_in_town(@claim.nearest_town)
    #  attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
    #  mail(:to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMI Claim No. #{@claim.claim_no}")
    #rescue
    #  #  Do nothing
    #end
  end

end

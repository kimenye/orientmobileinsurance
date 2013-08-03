class CustomerMailer < ActionMailer::Base

  default :from => "robot@omi.co.ke"

  def claim_registration(claim)
    @claim = claim
    attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
    mail(:to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMI Claim Registartion Details")
  end

  def policy_purchase(policy)
    @policy = policy
    attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
    attachments['omi.pdf'] = File.read("#{Rails.root}/doc/data/Orient Mobile - Policy Terms & Conditions.pdf")
    mail(:to => "#{@policy.quote.insured_device.customer.name} <#{@policy.quote.insured_device.customer.email}>", :subject => "OMI Policy Purchase")
  end

  def claim_decline(claim)
    @claim = claim
    attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
    mail(:to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMI Claim No. #{@claim.claim_no}")
  end

  def reparable_damage_claim(claim)
    @claim = claim
    attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
    mail(:to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMI Claim No. #{@claim.claim_no}")
  end

  def irreparable_damage_claim(claim)
    @claim = claim
    attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
    mail(:to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMI Claim No. #{@claim.claim_no}")
  end

  def loss_theft_claim(claim)
    @claim = claim
    attachments.inline['admin_banner.jpg'] = File.read("#{Rails.root}/app/assets/images/admin_banner.jpg")
    mail(:to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMI Claim No. #{@claim.claim_no}")
  end

end

class CustomerMailer < ActionMailer::Base

  default :from => "robot@omi.co.ke"

  def claim_registration(claim)
    @claim = claim
    mail(:to => "#{@claim.policy.quote.insured_device.customer.name} <#{@claim.policy.quote.insured_device.customer.email}>", :subject => "OMI Claim Registartion Details")
  end

  def policy_purchase(policy)
    @policy = policy
    mail(:to => "#{@policy.quote.insured_device.customer.name} <#{@policy.quote.insured_device.customer.email}>", :subject => "OMI Policy Purchase")
  end

end

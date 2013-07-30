class CustomerMailer < ActionMailer::Base
  default from: "from@example.com"

  default :from => "robot@omi.co.ke"

  def claim_registration(customer)
    @customer = customer
    mail(:to => "#{customer.name} <#{customer.email}>", :subject => "OMI Claim Registartion Details")
  end

  def policy_purchase(customer)
    @customer = customer
    mail(:to => "#{customer.name} <#{customer.email}>", :subject => "OMI Policy Purchase")
  end

end

require 'test_helper'

class CustomerMailerTest < ActionMailer::TestCase

  after do
    Customer.delete_all
    Device.delete_all
    InsuredDevice.delete_all
    Policy.delete_all
    Quote.delete_all
    Claim.delete_all
  end

  tests CustomerMailer
  test "send claim registration email" do

    @customer = Customer.create! :name => "Joyce", :id_passport => "123456789", :email => "jokhessa@yahoo.com", :phone_number => "254705866564"
    @device = Device.create! :vendor => "Apple", :model => "IPHONE 5 - 16GB", :marketing_name => "IPHONE 5 - 16GB", :wholesale_price => 100.00, :catalog_price => 150.00
    @insured_device = InsuredDevice.create! :customer_id => @customer.id, :device_id => @device.id, :imei => "0987654321"
    @quote = Quote.create! :account_name => "ABCDEFGHI", :insured_device_id => @insured_device.id
    @policy = Policy.create! :quote_id => @quote.id, :start_date => 365.days.ago
    @claim = Claim.create! :policy_id => @policy.id, :incident_date => 300.days.ago, :nearest_town => 'Nairobi'

    # Send the email, then test that it got queued

    email = CustomerMailer.claim_registration(@claim).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal ['ombclaims@korient.co.ke'], email.from
    assert_equal ['jokhessa@yahoo.com'], email.to
    assert_equal 'OMB Claim Registration Details. Claim No. ', email.subject
  end

  test "send policy email" do

    @customer = Customer.create! :name => "Test", :id_passport => "123456789", :email => "jokhessa@yahoo.com", :phone_number => "254705866564"
    @device = Device.create! :vendor => "Apple", :model => "IPHONE 5 - 16GB", :marketing_name => "IPHONE 5 - 16GB", :wholesale_price => 100.00, :catalog_price => 150.00
    @insured_device = InsuredDevice.create! :customer_id => @customer.id, :device_id => @device.id, :imei => "0987654321"
    @quote = Quote.create! :account_name => "ABCDEFGHI", :insured_device_id => @insured_device.id
    @policy = Policy.create! :quote_id => @quote.id, :start_date => 365.days.ago, :expiry => 2.days.from_now
    @claim = Claim.create! :policy_id => @policy.id, :incident_date => 300.days.ago

    # Send the email, then test that it got queued

    email = CustomerMailer.policy_purchase(@policy).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal ['mobile@korient.co.ke'], email.from
    assert_equal ['jokhessa@yahoo.com'], email.to
    assert_equal 'OMB Policy Purchase. Policy No. ', email.subject
  end
end

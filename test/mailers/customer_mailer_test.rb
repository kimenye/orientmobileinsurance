require 'test_helper'

class CustomerMailerTest < ActionMailer::TestCase

  after do
    Customer.delete_all
  end

  tests CustomerMailer
  test "send email" do

    @customer = Customer.create! :name => "Test", :id_passport => "123456789", :email => "jokhessa@yahoo.com", :phone_number => "254705866564"

    # Send the email, then test that it got queued

    email = CustomerMailer.claim_registration(@customer).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal ['robot@omi.co.ke'], email.from
    assert_equal ['jokhessa@yahoo.com'], email.to
    assert_equal 'OMI Claim Registartion Details', email.subject
  end
end

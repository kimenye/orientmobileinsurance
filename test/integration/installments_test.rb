require "test_helper"

class InstallmentsTest < ActionDispatch::IntegrationTest

  before do
    @service = PremiumService.new
  end

  after do
    Claim.delete_all
    Policy.delete_all
    Quote.delete_all
    InsuredDevice.delete_all
    Customer.delete_all
    Device.delete_all
  end

  it "A serial claimant is an applicant that has made 3 claims in any 12-month period" do
    Policy.delete_all
    @device = Device.create! :vendor => "Apple", :model => "IPHONE 5 - 16GB", :marketing_name => "IPHONE 5 - 16GB", :catalog_price => 3000.00
    @customer = Customer.create! :name => "Test", :id_passport => "123456789", :email => "test@domain.com", :phone_number => "254705866564"
    @insured_device = InsuredDevice.create! :customer_id => @customer.id, :device_id => @device.id

    @quote = Quote.create! :account_name => "ABCDEFGHI", :insured_device_id => @insured_device.id, :premium_type => "six_monthly"
    @policy = Policy.create! :quote_id => @quote.id, :insured_device_id => @insured_device.id #, :start_date => 365.days.ago

    installments = @service.calculate_monthly_premium "code", 3000, Time.now.year, 6
    @quote.monthly_premium = installments
    @quote.save!
    Payment.create! :policy_id => @policy.id, :amount => 115.00

    payment_service = PaymentService.new
    n = 1
    Payment.delete_all
    6.times do
      Payment.create! :policy_id => @policy.id, :amount => 115.00
      @policy = Policy.first
      PremiumService.set_policy_dates @policy
      @policy.save!
      if n != 6
        assert_equal 30.days.from_now.year, @policy.expiry.year
        assert_equal 30.days.from_now.month, @policy.expiry.month
        assert_equal 30.days.from_now.day, @policy.expiry.day
      else
        assert_equal (@policy.start_date + 365.days).year, @policy.expiry.year
        assert_equal (@policy.start_date + 365.days).month, @policy.expiry.month
        assert_equal (@policy.start_date + 365.days).day, @policy.expiry.day
      end
      assert_equal 690 - (115*n), @policy.pending_amount
      n+=1
    end
  end
end
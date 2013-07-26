require "test_helper"

class ClaimServiceTest < ActionDispatch::IntegrationTest

  before do
    @service = ClaimService.new
  end

  after do
    Claim.delete_all
    Policy.delete_all
    Quote.delete_all
    InsuredDevice.delete_all
    Customer.delete_all
    Device.delete_all
  end

  it "Dates are within 12-months" do
    dates = [300.days.ago, 50.days.ago, 200.days.ago]

    within = @service.dates_in_same_calendar_year dates
    assert within, "Dates should be marked as being within 12 months"
  end

  it "A serial claimant is an applicant that has made 3 claims in any 12-month period" do

    @device = Device.create! :vendor => "Apple", :model => "IPHONE 5 - 16GB", :marketing_name => "IPHONE 5 - 16GB", :wholesale_price => 100.00, :catalog_price => 150.00
    @customer = Customer.create! :name => "Test", :id_passport => "123456789", :email => "test@domain.com", :phone_number => "254705866564"
    @insured_device = InsuredDevice.create! :customer_id => @customer.id, :device_id => @device.id

    @quote = Quote.create! :account_name => "ABCDEFGHI", :insured_device_id => @insured_device.id
    @policy = Policy.create! :quote_id => @quote.id, :start_date => 365.days.ago

    @claim_one = Claim.create! :policy_id => @policy.id, :incident_date => 300.days.ago
    @claim_two = Claim.create! :policy_id => @policy.id, :incident_date => 200.days.ago
    @claim_three = Claim.create! :policy_id => @policy.id, :incident_date => 50.days.ago

    service = ClaimService.new
    claimant = service.is_serial_claimant "123456789"
    assert claimant, "customer with three claims in a calendar period is a serial claimaint"
  end

  it "Finds brands in a town given the town name" do
    brand_fetch_from_db = Brand.find_by_town_name('Nairobi')
    brand_from_method_call = @service.find_brands_in_town('NAIROBI')
    assert_equal brand_fetch_from_db, brand_from_method_call
  end

end
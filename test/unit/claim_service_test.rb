require 'test_helper'

class ClaimServiceTest < ActiveSupport::TestCase

	before do
		Claim.delete_all
		Device.delete_all
	end

	test "The claim number should get the last claim in saved and add 1 to the index" do
		service = ClaimService.new

		Claim.create! :claim_type => "Theft", :claim_no => "C/OMB/AAAA/0023"

		claim_no = service.create_claim_no 
		assert_equal "C/OMB/AAAA/0024", claim_no
	end

	test "A claim number should be unique in the system" do
		Claim.create! :claim_type => "Theft", :claim_no => "C/OMB/AAAA/0023"

		c = Claim.new :claim_type => "Damage",  :claim_no => "C/OMB/AAAA/0023"
		assert_equal false, c.valid?
	end

	test "If a policy is for a device serviced by STL it should only return locations that have Simba Telecom" do		
		device = Device.create! :vendor => "iTel", :model => "N7", :marketing_name => "N7", :catalog_price => 5, :dealer_code => "STL"
		enquiry = Enquiry.create! :source => "SMS", :phone_number => "254705866564", :hashed_phone_number => "abc", :hashed_timestamp => "def"
    	customer = Customer.create! :name => "Test Customer", :id_passport => "1234567890", :phone_number => "254705866564", :email => "kimenye@gmail.com"
    	insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => device.id, :imei => "123456789012345", :yop => 2013, :phone_number => "254705866564"
    	quote = Quote.create! :insured_device_id => insured_device.id, :insured_value => 1000, :premium_type => "Annual", :annual_premium => 300, :monthly_premium => 200, :account_name => "OMIXRY9832", :expiry_date => 3.days.from_now, :agent_id => nil
    	policy = Policy.create! :policy_number => "AAA/000", :quote_id => quote.id, :status => "Active", :start_date => Time.now, :expiry => 1.year.from_now, :insured_device_id => insured_device.id
    	payment = Payment.create! :method => "JP", :policy_id => policy.id, :amount => 300, :reference => "ABC"
    	
    	claim = Claim.new ({:policy_id => policy.id})

    	brand0 = Brand.create! :town_name => "Nairobi", :brand_1 => "Simba Telecom"
    	brand1 = Brand.create! :town_name => "Nakuru", :brand_1 => "Simba Telecom"
    	brand2 = Brand.create! :town_name => "Nakuru", :brand_1 => "PhoneLink", :brand_2 => "Simba Telecom"
    	brand3 = Brand.create! :town_name => "Nakuru", :brand_1 => "PhoneLink"

    	service = ClaimService.new
        assert_equal true, claim.is_stl_only
    	locations = service.find_nearest_locations claim
    	assert_equal 3, locations.length
	end

    test "If a policy is for a device serviced by BOTH and the code is for STL then it should only return locations that have Simba Telecom" do
        device = Device.create! :vendor => "Blackberry", :model => "N7", :marketing_name => "N7", :catalog_price => 5, :dealer_code => "Both"
        enquiry = Enquiry.create! :source => "SMS", :phone_number => "254705866564", :hashed_phone_number => "abc", :hashed_timestamp => "def"
        customer = Customer.create! :name => "Test Customer", :id_passport => "1234567890", :phone_number => "254705866564", :email => "kimenye@gmail.com"
        insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => device.id, :imei => "123456789012345", :yop => 2013, :phone_number => "254705866564"
        agent = Agent.create! :outlet_name => "STL", :code => "STL050"
        quote = Quote.create! :insured_device_id => insured_device.id, :insured_value => 1000, :premium_type => "Annual", :annual_premium => 300, :monthly_premium => 200, :account_name => "OMIXRY9832", :expiry_date => 3.days.from_now, :agent_id => agent.id
        policy = Policy.create! :policy_number => "AAA/000", :quote_id => quote.id, :status => "Active", :start_date => Time.now, :expiry => 1.year.from_now, :insured_device_id => insured_device.id
        payment = Payment.create! :method => "JP", :policy_id => policy.id, :amount => 300, :reference => "ABC"
        
        claim = Claim.new ({:policy_id => policy.id})

        brand0 = Brand.create! :town_name => "Nairobi", :brand_1 => "Simba Telecom"
        brand1 = Brand.create! :town_name => "Nakuru", :brand_1 => "Simba Telecom"
        brand2 = Brand.create! :town_name => "Nakuru", :brand_1 => "PhoneLink", :brand_2 => "Simba Telecom"
        brand3 = Brand.create! :town_name => "Nakuru", :brand_1 => "PhoneLink"

        service = ClaimService.new
        locations = service.find_nearest_locations claim
        assert_equal 3, locations.length
    end

	test "If a claim is only serviced by STL then only the STL brand should be shown" do
		device = Device.create! :vendor => "Tecno", :model => "N7", :marketing_name => "N7", :catalog_price => 5
		enquiry = Enquiry.create! :source => "SMS", :phone_number => "254705866564", :hashed_phone_number => "abc", :hashed_timestamp => "def"
    	customer = Customer.create! :name => "Test Customer", :id_passport => "1234567890", :phone_number => "254705866564", :email => "kimenye@gmail.com"
    	insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => device.id, :imei => "123456789012345", :yop => 2013, :phone_number => "254705866564"
    	quote = Quote.create! :insured_device_id => insured_device.id, :insured_value => 1000, :premium_type => "Annual", :annual_premium => 300, :monthly_premium => 200, :account_name => "OMIXRY9832", :expiry_date => 3.days.from_now, :agent_id => nil
    	policy = Policy.create! :policy_number => "AAA/000", :quote_id => quote.id, :status => "Active", :start_date => Time.now, :expiry => 1.year.from_now, :insured_device_id => insured_device.id
    	payment = Payment.create! :method => "JP", :policy_id => policy.id, :amount => 300, :reference => "ABC"
    	
    	claim = Claim.new ({:policy_id => policy.id, :nearest_town => "Nakuru"})

    	brand0 = Brand.create! :town_name => "Nairobi", :brand_1 => "Simba Telecom"
    	brand1 = Brand.create! :town_name => "Embu", :brand_1 => "Simba Telecom"
    	brand2 = Brand.create! :town_name => "Nakuru", :brand_1 => "PhoneLink", :brand_2 => "Simba Telecom"
    	brand3 = Brand.create! :town_name => "Naivasha", :brand_1 => "PhoneLink"

    	service = ClaimService.new

    	brands = service.find_nearest_brands claim.nearest_town, true
    	assert_equal 1, brands.length
	end

    test "The replacement value should be the insured value - excess where the excess is 10% of insured value" do
        device = Device.create! :vendor => "Tecno",
                                :model => "N7", 
                                :marketing_name => "N7", 
                                :catalog_price => 5, 
                                :dealer_code => "STL"

        enquiry = Enquiry.create! :source => "SMS", 
                                  :phone_number => "254705866564", 
                                  :hashed_phone_number => "abc", 
                                  :hashed_timestamp => "def"

        customer = Customer.create! :name => "Test Customer", 
                                    :id_passport => "1234567890", 
                                    :phone_number => "254705866564", 
                                    :email => "kimenye@gmail.com"

        insured_device = InsuredDevice.create! :customer_id => customer.id, 
                                               :device_id => device.id, 
                                               :imei => "123456789012345", 
                                               :yop => 2013, 
                                               :phone_number => "254705866564"

        quote = Quote.create! :insured_device_id => insured_device.id, 
                              :insured_value => 1000, 
                              :premium_type => "Annual", 
                              :annual_premium => 300, 
                              :monthly_premium => 200, 
                              :account_name => "OMIXRY9832", 
                              :expiry_date => 3.days.from_now, 
                              :agent_id => nil

        policy = Policy.create! :policy_number => "AAA/000", 
                                :quote_id => quote.id, 
                                :status => "Active", 
                                :start_date => Time.now,
                                :expiry => 1.year.from_now,
                                :insured_device_id => insured_device.id

        payment = Payment.create! :method => "JP", 
                                  :policy_id => policy.id, 
                                  :amount => 300, 
                                  :reference => "ABC"
        
        claim = Claim.new ({:policy_id => policy.id})

        claim_service = ClaimService.new
        replacement_value = claim_service.get_replacement_amount_for_claim (claim)
        assert_equal 0.9 * quote.insured_value, replacement_value


    end
end
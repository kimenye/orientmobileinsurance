require 'test_helper'

class PremiumServiceTest < ActiveSupport::TestCase

  test "Should insure phones purchased in the current year if no sales code is provided" do
    service = PremiumService.new
    insurable = service.is_insurable(Time.now.year, nil)
    assert true == insurable
    end

  test "Should insure phones purchased in the previous year if no sales code is provided" do
    service = PremiumService.new
    insurable = service.is_insurable(Time.now.year-1, nil)
    assert true == insurable
  end

  test "Should not insure phones purchased more than a year ago if no sales code is provided" do
    service = PremiumService.new
    insurable = service.is_insurable(Time.now.year-2, nil)
    assert false == insurable
  end

  test "Should insure phones if a valid sales code is provided" do
    service = PremiumService.new
    insurable = service.is_insurable(Time.now.year-2, "test")
    assert true == insurable, "Should insure any phones if sales code is given"
  end

  test "Insurance value should be 100% of catalogue price if sales code starts with FX" do
    service = PremiumService.new
    insurance_value = service.calculate_insurance_value(800, "FX001" , Time.now.year)
    assert insurance_value == 800, "Catalogue price should equal insurance value"
  end

  test "Insurance value should be 87.5% of catalogue price if sales code does not start with FX and year of purchase is same as current year" do
    service = PremiumService.new
    insurance_value = service.calculate_insurance_value(800, "JM001" , Time.now.year)
    assert insurance_value == (0.875 * 800), "Catalogue price should be 87.5%"
  end

  test "Insurance value should be 37.5% of catalogue price if sales code does not start with FX and year of purchase is less than current year" do
    service = PremiumService.new
    insurance_value = service.calculate_insurance_value(800, "JM001" , Time.now.year - 1)
    assert insurance_value == (0.375 * 800), "Catalogue price should be 37.5%"
  end

  test "The correct premium rate is returned based on the sales agent code" do
    service = PremiumService.new

    rate = service.calculate_premium_rate "FX000"
    assert rate == 0.095, "Premium rate should be 9.5% for FX codes"

    rate = service.calculate_premium_rate "83000"
    assert rate == 0.1, "Premium rate should be 10% for non FX codes"

    rate = service.calculate_premium_rate nil
    assert rate == 0.1, "Premium rate should be 10% for empty"
  end

  test "MPESA service charges should be correctly calculated" do
    service = PremiumService.new

    fee = service.calculate_mpesa_fee(10)
    assert fee == 0, "Fee should be free from 0-999"

    fee = service.calculate_mpesa_fee(1000)
    assert fee == 11, "Fee should be 11 for greater than 999"

    fee = service.calculate_mpesa_fee(2499)
    assert fee == 11, "Fee should be 11 for greater than 999"

    fee = service.calculate_mpesa_fee(2500)
    assert fee == 33, "Fee should be 33 for greater than 2499"

    fee = service.calculate_mpesa_fee(5000)
    assert fee == 61, "Fee should be 61 for greater than 5000"

    fee = service.calculate_mpesa_fee(9998)
    assert fee == 61, "Fee should be 61 for greater than 5000"

    fee = service.calculate_mpesa_fee(10001)
    assert fee == 77, "Fee should be 77 for greater than 10000"

    fee = service.calculate_mpesa_fee(19999)
    assert fee == 77, "Fee should be 77 for greater than 10000"

    fee = service.calculate_mpesa_fee(21000)
    assert fee == 132, "Fee should be 132 for greater than 20000"

    fee = service.calculate_mpesa_fee(36000)
    assert fee == 154, "Fee should be 154 for greater than 35000"

    fee = service.calculate_mpesa_fee(65000)
    assert fee == 165, "Fee should be 165 for greater than 50000"
  end

  test "can generate a random six digit account number" do
    service = PremiumService.new
    number = service.generate_unique_account_number

    assert_equal number.length, 6, "Account number should be six characters long"
  end

  test "can verify an IMEI" do
    service = PremiumService.new

    assert (service.is_imei? "123456789012345")
    assert_equal false, (service.is_imei? "")
    assert_equal false, (service.is_imei? "123213213")
    assert_equal false, (service.is_imei? "123213213sdfdsf")
  end

  test "can tell the type of message based on the text" do
    service = PremiumService.new

    assert_equal 2, (service.get_message_type "OMI", "123456789012345")
    assert_equal 2, (service.get_message_type "OMI", "123456789012345")
  end

  test "A status message is displayed for a policy that cannot be claimed" do
    service = PremiumService.new
    quote = Quote.new ({ :account_name => "account", :premium_type => "Annual", :annual_premium => 10 })

    expected = "The Orient Mobile policy for this device has an outstanding balance of KES 10. Your account no. is account. Please pay via MPesa (Business No. #{ENV['MPESA']}) or Airtel Money (Business Name #{ENV['AIRTEL']}).  You can register your claim after payment confirmation."
    msg = service.get_status_message quote
    assert_equal expected, msg
  end
  
  test "Annual Premium calculation rules" do
    service = PremiumService.new
    premium = service.calculate_annual_premium "FX", 5199 
    assert_equal 914, premium    
    
    premium = service.calculate_annual_premium "FW", 4550 
    assert_equal 1025, premium    
  
    premium = service.calculate_annual_premium "FW", 1950 
    assert_equal 1025, premium        
  end
  
  test "Montly Premium calculation rules" do
    service = PremiumService.new
    premium = service.calculate_monthly_premium "FX", 5199 
    assert_equal 349, premium    
    
    premium = service.calculate_monthly_premium "FW", 4550 
    assert_equal 387, premium    
  
    premium = service.calculate_monthly_premium "FW", 1950 
    assert_equal 387, premium       
  end
  
end
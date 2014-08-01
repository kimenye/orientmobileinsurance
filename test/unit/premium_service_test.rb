require 'test_helper'

class PremiumServiceTest < ActiveSupport::TestCase
  test "Should insure phones purchased in the current year if no sales code is provided" do
    service = PremiumService.new
    insurable = service.is_insurable Time.now.year
    assert true == insurable
  end

  test "Should insure phones purchased within the last two years" do
    service = PremiumService.new
    month = Device.month_ranges[15].split(" ")[0]
    year = Device.month_ranges[15].split(" ")[1]
    insurable = service.is_insurable_by_month_and_year month, year
    assert_equal true, insurable
  end

  test "Should not insure phones not purchased within the last two years" do
    service = PremiumService.new
    month = Date::MONTHNAMES[Time.now.month - 1]
    year = Time.now.year - 2
    puts "Month => #{month} \n Year => #{year}"
    insurable = service.is_insurable_by_month_and_year month, year
    assert_equal false, insurable
  end

  test "Should return true for Fone Direct outlets" do
    service = PremiumService.new
    result = service.is_fx_code "FXP002"
    assert_equal result, true, "Should return true for FX codes"

    result = service.is_fx_code "TSK001"
    assert_equal result, true, "Should return true for TSK codes"

    result = service.is_fx_code "NVS008"
    assert_equal result, true, "Should return true for NVS codes"

    result = service.is_fx_code "PLK004"
    assert_equal result, true, "Should return true for PLK codes"
  end

  test "Should insure phones purchased in the previous year if no sales code is provided" do
    service = PremiumService.new
    insurable = service.is_insurable Time.now.year-1
    assert true == insurable
  end

  test "An STL code starts with STL" do
    service = PremiumService.new
    assert_equal true, service.is_stl_code("STL001")
    assert_equal false, service.is_stl_code("FXP000")
  end

  test "Should not insure phones purchased more than a year ago if no sales code is provided" do
    service = PremiumService.new
    insurable = service.is_insurable Time.now.year-2
    assert false == insurable
  end

  test "Insurance value should be 100% of catalogue price if sales code starts with FX or STL" do
    service = PremiumService.new
    insurance_value = service.calculate_insurance_value(800, "FXP001" , Time.now.year)
    assert insurance_value == 800, "Catalogue price should equal insurance value"

    insurance_value = service.calculate_insurance_value(800, "STL001" , Time.now.year)
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

  test "Discount should be deducted from the insurance value if the agent has a discount set" do
    service = PremiumService.new
    yop = Time.now.year - 1
    Agent.delete_all
    agent = Agent.create! outlet_name: "Blah", code: "JM001", discount: 10
    percentage_after_discount = (100 - agent.discount) / 100
    insurance_value = service.calculate_insurance_value(800, agent.code , yop)
    annual_premium = service.calculate_annual_premium(agent.code, insurance_value, yop)
    raw = service.calculate_premium_rate(agent.code, yop) * insurance_value
    raw = 1.0045 * raw
    raw = [raw.round, service.minimum_fee(agent.code, yop)].max
    raw += 15
    raw += service.calculate_mpesa_fee(raw)
    expected_premium = [service.round_off((percentage_after_discount * raw).round), service.minimum_fee(agent.code, yop)].max
    puts "insurance_value => #{insurance_value}, annual_premium => #{annual_premium}"
    assert_equal expected_premium, annual_premium

    base_premium = service.calculate_annual_premium agent.code, insurance_value, yop, false, false, true
    raw = service.calculate_total_installment base_premium
    expected_premium = service.round_off((raw / 3).ceil)
    monthly_premium = service.calculate_monthly_premium(agent.code, insurance_value, yop)
    assert_equal expected_premium, monthly_premium
  end

  test "The correct premium rate is returned based on the sales agent code and year of purchase" do
    service = PremiumService.new

    rate = service.calculate_premium_rate "FXP000", Time.now.year
    assert rate == 0.095, "Premium rate should be 9.5% for FX codes if year of purchase is current year"

    rate = service.calculate_premium_rate "83000", Time.now.year
    assert rate == 0.1, "Premium rate should be 10% for non FX codes"

    rate = service.calculate_premium_rate nil, Time.now.year
    assert rate == 0.1, "Premium rate should be 10% for empty"

    rate = service.calculate_premium_rate "FXP000", (Time.now.year - 1)
    assert rate == 0.1, "Premium rate should be 10% for FX codes if year of purchase is previous year"
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

    assert_equal 2, (service.get_message_type "123456789012345")
    assert_equal 2, (service.get_message_type "123456789012345")
    assert_equal 1, (service.get_message_type "Mobile")
    assert_equal 1, (service.get_message_type "Mobi")
    assert_equal 1, (service.get_message_type "MOBI")
    assert_equal 1, (service.get_message_type "Mombile")
    assert_equal 1, (service.get_message_type "Phone")
    assert_equal 3, (service.get_message_type "OMI")
    assert_equal 3, (service.get_message_type "OMI 123456789012345")
    assert_equal 3, (service.get_message_type "Mobile 123456789012345")
  end

  test "A status message is displayed for a policy that cannot be claimed" do
    service = PremiumService.new
    quote = Quote.new ({ :account_name => "account", :premium_type => "Annual", :annual_premium => 10 })

    expected = "The Orient Mobile policy for this device has an outstanding balance of KES 10. Your account no. is account. Please pay via MPesa (Business No. #{ENV['MPESA']}) or Airtel Money (Business Name #{ENV['AIRTEL']}).  You can register your claim after payment confirmation."
    msg = service.get_status_message quote
    assert_equal expected, msg
  end

  test "The minimum premium fee should be based on the year of purchase and agent code" do
    service = PremiumService.new

    result = service.minimum_fee "FXP001", Time.now.year
    assert_equal 899, result

    result = service.minimum_fee "XXXXXX", Time.now.year
    assert_equal 595, result

    result = service.minimum_fee "FXP001", (Time.now.year-1)
    assert_equal 595, result

    result = service.minimum_fee "XXXXXX", (Time.now.year-1)
    assert_equal 595, result

  end

  test "Annual Premium calculation rules" do
    service = PremiumService.new
    Agent.delete_all
    agent_fx = Agent.create! outlet_name: "out", code: "FXP001", discount: 0
    agent_xx = Agent.create! outlet_name: "out", code: "XXXXXX", discount: 0
    agent_three = Agent.create! outlet_name: "out", code: "XXX000", discount: 0
    agent_four = Agent.create! outlet_name: "out", code: "000000", discount: 0

    #Nokia ASHA 205
    premium = service.calculate_annual_premium agent_fx.code, 6150, Time.now.year
    assert_equal 915, premium

    premium = service.calculate_annual_premium agent_three.code, 5380, Time.now.year
    assert_equal 610, premium

    premium = service.calculate_annual_premium agent_fx.code, 2310, (Time.now.year - 1)
    assert_equal 610, premium

    premium = service.calculate_annual_premium agent_xx.code, 2310, (Time.now.year - 1)
    assert_equal 610, premium

    #Samsung Note II
    premium = service.calculate_annual_premium agent_fx.code, 58999, Time.now.year
    assert_equal 5705, premium
    #
    premium = service.calculate_annual_premium agent_four.code, 51620, Time.now.year
    assert_equal 5260, premium

    premium = service.calculate_annual_premium agent_four.code, 22120, (Time.now.year - 1)
    assert_equal 2250, premium

    premium = service.calculate_annual_premium agent_fx.code, 22120, (Time.now.year - 1)
    assert_equal 2250, premium
  end


  test "Raw premium calculation rules" do
    service = PremiumService.new
    Agent.delete_all
    agent_fx = Agent.create! outlet_name: "out", code: "FXP001", discount: 0
    agent_xx = Agent.create! outlet_name: "out", code: "XXXXXX", discount: 0
    agent_three = Agent.create! outlet_name: "out", code: "XXX000", discount: 0
    agent_four = Agent.create! outlet_name: "out", code: "000000", discount: 0

    raw = service.calculate_raw_annual_premium agent_fx.code, 6150, Time.now.year
    assert_equal 899, raw

    premium = service.calculate_raw_annual_premium agent_three.code, 5380, Time.now.year
    assert_equal 595, premium

    premium = service.calculate_raw_annual_premium agent_fx.code, 2310, (Time.now.year - 1)
    assert_equal 595, premium

    premium = service.calculate_raw_annual_premium agent_xx.code, 2310, (Time.now.year - 1)
    assert_equal 595, premium

    premium = service.calculate_raw_annual_premium agent_fx.code, 58999, Time.now.year
    assert_equal 5605, premium

    premium = service.calculate_raw_annual_premium agent_four.code, 51620, Time.now.year
    assert_equal 5162, premium

    premium = service.calculate_raw_annual_premium agent_four.code, 22120, (Time.now.year - 1)
    assert_equal 2212, premium

    premium = service.calculate_raw_annual_premium agent_fx.code, 22120, (Time.now.year - 1)
    assert_equal 2212, premium
  end

  test "Raw monthly premium calculation rules" do
    service = PremiumService.new
    Agent.delete_all
    agent_fx = Agent.create! outlet_name: "out", code: "FXP001", discount: 0
    agent_xx = Agent.create! outlet_name: "out", code: "XXXXXX", discount: 0
    agent_three = Agent.create! outlet_name: "out", code: "XXX000", discount: 0
    agent_four = Agent.create! outlet_name: "out", code: "000000", discount: 0

    raw = service.calculate_raw_monthly_premium agent_fx.code, 6150, Time.now.year
    assert_equal 345, raw

    premium = service.calculate_raw_monthly_premium agent_three.code, 5380, Time.now.year
    assert_equal 228, premium

    premium = service.calculate_raw_monthly_premium agent_fx.code, 2310, (Time.now.year - 1)
    assert_equal 228, premium

    premium = service.calculate_raw_monthly_premium agent_xx.code, 2310, (Time.now.year - 1)
    assert_equal 228, premium

    premium = service.calculate_raw_monthly_premium agent_fx.code, 58999, Time.now.year
    assert_equal 2149, premium

    premium = service.calculate_raw_monthly_premium agent_four.code, 51620, Time.now.year
    assert_equal 1979, premium

    premium = service.calculate_raw_monthly_premium agent_four.code, 22120, (Time.now.year - 1)
    assert_equal 848, premium

    premium = service.calculate_raw_monthly_premium agent_fx.code, 22120, (Time.now.year - 1)
    assert_equal 848, premium
  end

  test "Levy calculation" do
    service = PremiumService.new

    levy = service.calculate_levy 899
    assert_equal levy, 4
  end

  test "Monthly Premium calculation rules" do
    service = PremiumService.new
    Agent.delete_all
    agent_fx = Agent.create! outlet_name: "out", code: "FXP001", discount: 0
    agent_xo = Agent.create! outlet_name: "out", code: "XXX000", discount: 0

    #Nokia ASHA
    premium = service.calculate_monthly_premium agent_fx.code, 5199, Time.now.year
    assert_equal 350, premium

    premium = service.calculate_monthly_premium agent_xo.code, 5380, Time.now.year
    assert_equal 235, premium

    premium = service.calculate_monthly_premium agent_fx.code, 2310, (Time.now.year - 1)
    assert_equal 235, premium

    premium = service.calculate_monthly_premium agent_xo.code, 2310, (Time.now.year - 1)
    assert_equal 235, premium

    #Samsung Note 2
    premium = service.calculate_monthly_premium agent_fx.code, 58999, Time.now.year
    assert_equal 2175, premium

    premium = service.calculate_monthly_premium agent_xo.code, 51620, Time.now.year
    assert_equal 2005, premium

    premium = service.calculate_monthly_premium agent_fx.code, 22120, (Time.now.year - 1)
    assert_equal 855, premium

    premium = service.calculate_monthly_premium agent_xo.code, 22120, (Time.now.year - 1)
    assert_equal 855, premium
  end

  test "Should not be able to use the same IMEI device if it has an active policy" do
    InsuredDevice.delete_all
    insured_device = InsuredDevice.create! :imei => "123456789012345", :yop => 2013
    quote = Quote.create! :insured_device_id => insured_device.id, :insured_value => 1000, :premium_type => "Annual", :annual_premium => 300, :monthly_premium => 200, :account_name => "OMIXRY9832", :expiry_date => 3.days.from_now
    policy = Policy.create! :policy_number => "AAA/000", :quote_id => quote.id, :status => "Active", :start_date => Time.now, :expiry => 1.year.from_now, :insured_device_id => insured_device.id

    service = PremiumService.new
    result = service.is_valid_imei? "animeinumberthatdoesntexist"

    assert_equal result, true

    result = service.is_valid_imei? "123456789012345"
    assert_equal result, false
  end

  test "Should generate the right policy number in the case where some data may have been deleted" do
    Policy.delete_all

    seed = ENV['SEED_POLICY_NO'].to_i

    service = PremiumService.new
    expected = "OMB/AAAA/000#{seed}"
    result = service.generate_unique_policy_number
    assert_equal expected, result

    id = InsuredDevice.create! :imei => "123456789012345", :yop => 2013

    policy = Policy.create! :policy_number => "AAA/000", :status => "Active", :start_date => Time.now, :expiry => 1.year.from_now, :insured_device_id => id.id
    expected = "OMB/AAAA/000#{seed+1}"
    result = service.generate_unique_policy_number
    assert_equal expected, result

    policy = Policy.create! :policy_number => "AAA/000", :status => "Active", :start_date => Time.now, :expiry => 1.year.from_now, :insured_device_id => id.id
    expected = "OMB/AAAA/000#{seed+2}"
    result = service.generate_unique_policy_number
    assert_equal expected, result
  end

  test "Rounds off number to the nearest 5 shillings" do
    number01 = 5086
    number02 = 1234
    number03 = 5087
    number04 = 5084

    service = PremiumService.new

    assert_equal 5085, service.round_off(number01)
    assert_equal 1235, service.round_off(number02)
    assert_equal 5085, service.round_off(number03)
    assert_equal 5085, service.round_off(number04)
  end

end
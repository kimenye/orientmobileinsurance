ActiveAdmin.register Policy, :as => "Customer" do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  index do
    column "Customer" do |policy|
      policy.customer.name
    end
    column :policy_number
    column :start_date
    column :expiry
    column :payment_option
    column "Total Due", :premium
    column "Amount Paid", :amount_paid
    column "Total Balance", :pending_amount
    column "Next Payment Due", :minimum_due
    column "IMEI", :imei
    column :sales_agent_code
    column :sales_agent_name
  end

  filter :policy_number
  filter :start_date
  filter :expiry
  filter :quote_account_name, :as => :string, :label => "Account Name"
  filter :quote_insured_device_customer_name, :as => :string, :label => "Customer Name"
  filter :quote_insured_device_phone_number, :as => :string, :label => "Phone Number"

  xlsx(:header_style => {:bg_color => 'C0BFBF', :fg_color => '000000' }) do

    ## deleting columns from the report

    delete_columns :id, :created_at, :updated_at, :expiry, :policy_number, :start_date, :status, :quote_id

    ## adding a column to the report
    column("TTY") { |p| "N" }
    column("CODE") { |p| p.policy_number }
    column("CLIENT NAME") {|p| p.quote.insured_device.customer.name }
    column("NATIONAL ID") { |p| p.quote.insured_device.customer.id_passport }
    column("PIN") { |p| 0 }
    column("POSTAL_ADDRS") { |p| "P.O.Box 00000" }
    column("POSTAL_TOWN") { |p| "NAIROBI" }
    column("POSTAL_CODE") { |p| "00000" }
    column("TELEPHONE NO") { |p| "#{p.quote.insured_device.customer.contact_number}" }
    column("MOBILE NO") { |p| "#{p.quote.insured_device.customer.contact_number}" }
    column("COUNTRY") { |p| "KENYA" }
    column("EFF DATE") {|p| (p.start_date.to_s(:export) if !p.start_date.nil?) }
    column("EXP DATE") {|p| (p.expiry.to_s(:export) if !p.expiry.nil?) }
    column("POL NO") {|p| "KOI/OMB/000001/2013" }
    column("RISK DESCRIPTION") { |p| p.quote.insured_device.device.marketing_name }
    column("INV DATE") { |p| (p.start_date.to_s(:export) if !p.start_date.nil?) }
    column("INV NO") { |p| "00000" }
    column("PREMIUM") { |p|
      service = PremiumService.new
      premium = 0
      if p.quote.is_installment?
        premium = service.calculate_raw_monthly_premium(p.quote.agent_code, p.quote.insured_value, p.quote.insured_device.yop)
      else
        premium = service.calculate_raw_annual_premium(p.quote.agent_code, p.quote.insured_value, p.quote.insured_device.yop)
      end
      premium
    }
    column("LEVIES") { |p|
      service = PremiumService.new
      premium = nil
      if p.quote.is_installment?
        premium = service.calculate_raw_monthly_premium(p.quote.agent_code, p.quote.insured_value, p.quote.insured_device.yop)
      else
        premium = service.calculate_raw_annual_premium(p.quote.agent_code, p.quote.insured_value, p.quote.insured_device.yop)
      end
      service.calculate_levy premium
    }
    column("Reg No") { |p| p.policy_number }
    column("Make/Model") { |p| p.quote.insured_device.device.marketing_name }
    column("Model/Type") { |p| p.quote.insured_device.device.marketing_name }
    column("YOM") { |p| p.quote.insured_device.yop }
    column("CC rate") { |p| "" }
    column("Chasis No.") { |p| "" }
    column("W/screen") { |p| 0 }
    column("Radio/Stereo") { |p| 0 }
    column("Cover Type") { |p| "STD" }
    column("Sum Insured") { |p| p.quote.insured_value }
    column("Cert No") { |p| "" }
    column("Section 5") { |p| 0 }
    column("Section 6") { |p| 0 }
    column("Section 7") { |p| 0 }
    column("Section 8") { |p| 0 }
    column("Section 9") { |p| p.sales_agent_code }
    column("Section 10") { |p| p.sales_agent_name }
  end

  csv do
    column("Customer") { |p| p.customer.name }
    column :policy_number
    column :start_date
    column :expiry
    column :payment_option
    column("Total Due") { |p| p.premium }
    column("Amount Paid") { |p| p.amount_paid }
    column("Total Balance") { |p| p.pending_amount }
    column("Next Payment Due") { |p| p.minimum_due }
    column("IMEI") { |p| p.imei }
    column :sales_agent_code
    column :sales_agent_name
    column ("Phone Number") { |p| p.quote.insured_device.phone_number }
  #  column("CODE") { |p| p.policy_number }
  #  column("CLIENT NAME") {|p| p.quote.insured_device.customer.name }
  #  column("NATIONAL ID") { |p| p.quote.insured_device.customer.id_passport }
  #  column("PIN") { |p| 0 }
  #  column("POSTAL_ADDRS") { |p| "P.O.Box 00000" }
  #  column("POSTAL_TOWN") { |p| "NAIROBI" }
  #  column("POSTAL_CODE") { |p| "00000" }
  #  column("TELEPHONE NO") { |p| "#{p.quote.insured_device.customer.contact_number.to_s}" }
  #  column("MOBILE NO") { |p| "#{p.quote.insured_device.customer.contact_number.to_s}" }
  #  column("COUNTRY") { |p| "KENYA" }
  #  column("EFF DATE") {|p| p.start_date.to_s(:export) }
  #  column("EXP DATE") {|p| p.expiry.to_s(:export) }
  #  column("POL NO") {|p| "KOI/OMB/000001/2013" }
  #  column("RISK DESCRIPTION") { |p| p.quote.insured_device.device.marketing_name }
  #  column("INV DATE") { |p| p.start_date.to_s(:export) }
  #  column("INV NO") { |p| "00000" }
  #  column("PREMIUM") { |p| "" }
  #  column("LEVIES") { |p| "" }
  #  column("Reg No") { |p| p.policy_number }
  #  column("Make/Model") { |p| p.quote.insured_device.device.marketing_name }
  #  column("Model/Type") { |p| p.quote.insured_device.device.marketing_name }
  #  column("YOM") { |p| p.quote.insured_device.yop }
  #  column("CC rate") { |p| "" }
  #  column("Chasis No.") { |p| "" }
  #  column("W/screen") { |p| 0 }
  #  column("Radio/Stereo") { |p| 0 }
  #  column("Cover Type") { |p| "STD" }
  #  column("Sum Insured") { |p| p.quote.insured_value }
  #  column("Cert No") { |p| "" }
  #  column("Section 5") { |p| 0 }
  #  column("Section 6") { |p| 0 }
  #  column("Section 7") { |p| 0 }
  #  column("Section 8") { |p| 0 }
  #  column("Section 9") { |p| "" }
  #  column("Section 10") { |p| "" }
  end
end

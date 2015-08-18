ActiveAdmin.register Policy, :as => "Customer" do
  scope :all
  scope :pending
  scope :active
  scope :expired
  scope :corporate
  scope :individual

  controller do
    actions :all, :except => [:edit, :destroy]
  end



  active_admin_import_anything do |file|
    
    doc = SimpleXlsxReader.open(file.tempfile)
        
    main_sheet = doc.sheets.first
    corporate_name = main_sheet.rows.first[2]
    sales_agent_code = main_sheet.rows[2][2]
    policy_type = main_sheet.rows[3][2]
    payment_mode = main_sheet.rows[4][2]

    main_sheet.rows[6..main_sheet.rows.length].each do |row|      
      model = row[1]
      imei = row[2]
      date_of_purchase = row[3]
      insured_value = row[4]
      total_paid = row[5]
      replacement_value = row[7]
      payment_date = row[8]
      payment_ref = row[10]
      policy_start = row[11]
      policy_end = row[12]
      email = row[13]
      number = row[14]
      id = row[15]

      if !row[0].nil? && !row[0].empty?
        PolicyService.create_corporate_policy corporate_name, id, email, number, policy_type, sales_agent_code, payment_mode, model,
          payment_date, insured_value, replacement_value, total_paid, payment_ref, imei, policy_start, policy_end
      end
    end
  end

  index do
    column "Customer" do |policy|
      link_to policy.customer.name, admin_lead_path(policy.customer)
    end
    column "Contact Number" do |policy|
      policy.quote.customer.phone_number
    end
    column :policy_number
    column :start_date
    column :expiry
    column :payment_option
    column "Insured Value" do |policy|
      policy.insured_device.insurance_value
    end
    column "Total Due", :premium
    column "Amount Paid", :amount_paid
    column "Total Balance", :pending_amount
    column "Next Payment Due", :pending_amount
    column "YOP" do |policy|
      policy.insured_device.yop
    end
    column "Device" do |policy|
      policy.insured_device.device.to_s
    end
    column "IMEI", :imei do |policy|
      link_to policy.insured_device.imei, admin_insured_device_path(policy.insured_device)
    end
    column :sales_agent_code
    column :sales_agent_name
    column :status
  end

  filter :policy_number
  filter :quote_type
  filter :start_date
  filter :expiry
  filter :quote_quote_type, :as => :string, :label => "Quote Type"
  filter :quote_account_name, :as => :string, :label => "Account Name"
  filter :quote_customer_name, :as => :string, :label => "Customer Name"
  filter :quote_customer_phone_number, :as => :string, :label => "Phone Number"

  # xlsx(:header_style => {:bg_color => 'C0BFBF', :fg_color => '000000' }) do

  #   ## deleting columns from the report

  #   delete_columns :id, :created_at, :updated_at, :expiry, :policy_number, :start_date, :status, :quote_id

  #   ## adding a column to the report
  #   column("TTY") { |p| "N" }
  #   column("CODE") { |p| p.policy_number }
  #   column("CLIENT NAME") {|p| p.quote.customer.name }
  #   column("NATIONAL ID") { |p| p.quote.customer.id_passport }
  #   column("PIN") { |p| 0 }
  #   column("POSTAL_ADDRS") { |p| "P.O.Box 00000" }
  #   column("POSTAL_TOWN") { |p| "NAIROBI" }
  #   column("POSTAL_CODE") { |p| "00000" }
  #   column("TELEPHONE NO") { |p| "#{p.quote.customer.contact_number}" }
  #   column("MOBILE NO") { |p| "#{p.quote.customer.contact_number}" }
  #   column("COUNTRY") { |p| "KENYA" }
  #   column("EFF DATE") {|p| (p.start_date.to_s(:export) if !p.start_date.nil?) }
  #   column("EXP DATE") {|p| (p.expiry.to_s(:export) if !p.expiry.nil?) }
  #   column("POL NO") {|p| "KOI/OMB/000001/2013" }
  #   column("RISK DESCRIPTION") { |p| p.insured_device.device.marketing_name }
  #   column("INV DATE") { |p| (p.start_date.to_s(:export) if !p.start_date.nil?) }
  #   column("INV NO") { |p| "00000" }
  #   column("PREMIUM") { |p|
  #     service = PremiumService.new
  #     premium = 0
  #     if p.quote.is_installment?
  #       premium = service.calculate_raw_monthly_premium(p.quote.agent_code, p.insured_device.insurance_value, p.insured_device.yop)
  #     else
  #       premium = service.calculate_raw_annual_premium(p.quote.agent_code, p.insured_device.insurance_value, p.insured_device.yop)
  #     end
  #     premium
  #   }
  #   column("LEVIES") { |p|
  #     service = PremiumService.new
  #     premium = nil
  #     if p.quote.is_installment?
  #       premium = service.calculate_raw_monthly_premium(p.quote.agent_code, p.insured_device.insurance_value, p.insured_device.yop)
  #     else
  #       premium = service.calculate_raw_annual_premium(p.quote.agent_code, p.insured_device.insurance_value, p.insured_device.yop)
  #     end
  #     service.calculate_levy premium
  #   }
  #   column("Reg No") { |p| "#{p.policy_number}/#{p.insured_device.imei}" }
  #   column("Make/Model") { |p| p.insured_device.device.marketing_name }
  #   column("Model/Type") { |p| p.insured_device.device.marketing_name }
  #   column("YOM") { |p| p.insured_device.yop }
  #   column("CC rate") { |p| "" }
  #   column("Chasis No.") { |p| "" }
  #   column("W/screen") { |p| 0 }
  #   column("Radio/Stereo") { |p| 0 }
  #   column("Cover Type") { |p| "STD" }
  #   column("Sum Insured") { |p| p.insured_device.insurance_value }
  #   column("Cert No") { |p| "" }
  #   column("Section 5") { |p| 0 }
  #   column("Section 6") { |p| 0 }
  #   column("Section 7") { |p| 0 }
  #   column("Section 8") { |p| 0 }
  #   column("Section 9") { |p| p.sales_agent_code }
  #   column("Section 10") { |p| p.sales_agent_name }
  # end

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
    column("YOP") { |p| p.insured_device.yop }
    column :sales_agent_code
    column :sales_agent_name
    column ("Phone Number") { |p| p.customer.phone_number }
  end
end

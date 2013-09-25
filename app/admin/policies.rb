ActiveAdmin.register Policy do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  index do
    column :policy_number
    column :customer
    column :start_date
    column :expiry
    column :status
    column "Premium", :premium
    column "Amount Paid", :amount_paid
    column :pending_amount
    column :minimum_paid
    column :minimum_due
  end
  actions :index, :show


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
    column("TELEPHONE NO") { |p| "#{p.quote.insured_device.customer.contact_number.to_s}" }
    column("MOBILE NO") { |p| "#{p.quote.insured_device.customer.contact_number.to_s}" }
    column("COUNTRY") { |p| "KENYA" }
    column("EFF DATE") {|p| p.start_date.to_s(:export) }
    column("EXP DATE") {|p| p.expiry.to_s(:export) }
    column("POL NO") {|p| "KOI/OMB/000001/2013" }
    column("RISK DESCRIPTION") { |p| p.quote.insured_device.device.marketing_name }
    column("INV DATE") { |p| p.start_date.to_s(:export) }
    column("INV NO") { |p| "00000" }
    column("PREMIUM") { |p| "" }
    column("LEVIES") { |p| "" }
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
    column("Section 9") { |p| "" }
    column("Section 10") { |p| "" }
  end

  #csv do
  #  column("TTY") { |p| "N" }
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
  #end
end

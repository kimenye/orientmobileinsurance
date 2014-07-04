ActiveAdmin.register InsuredDevice do

  controller do
    actions :all, :except => [:destroy]
  end
  active_admin_import_anything do |file|
    doc = SimpleXlsxReader.open(file.tempfile)
        
    main_sheet = doc.sheets.first
    # binding.pry
    customer = Customer.create! id: 0, name: "Nokia Devices", email: "dummy", phone_number: "34341", id_passport: "35235325" 
    quote = Quote.create! id: 0, quote_type: "Corporate", customer_id: customer.id
    Device.create! :vendor => "Nokia", :model => "Lumia 625", :marketing_name => "Nokia Lumia 625"
    main_sheet.rows[2..main_sheet.rows.length].each do |row|
      if !row[0].nil?
        imei = row[0].to_s[0..14]
        device = InsuredDevice.find_by_imei imei
        if device.nil?
          # create a new one
          device_id = Device.find_by_model("Lumia 625").id
          device = InsuredDevice.create! imei: imei, prepaid: true, activated: false, device_id: device_id, customer_id: customer.id
          Policy.create! insured_device_id: device.id, status: "Pending", quote_id: quote.id
            # :active => true
        else
          device.imei = imei
          device.save! 
        end
      end
    end
  end

  form do |f|
    f.inputs "Insured Device Details" do
        f.input :imei
    end
    f.actions
  end

  actions :index, :show, :edit, :update
end

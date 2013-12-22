ActiveAdmin.register Device do

  controller do
    actions :all, :except => [:destroy]
  end

  menu :parent => "Reference Data"

  active_admin_import_anything do |file|
    doc = SimpleXlsxReader.open(file.tempfile)
        
    main_sheet = doc.sheets.first
    # binding.pry
    main_sheet.rows[2..main_sheet.rows.length].each do |row|
      if !row[0].nil? && !row[0].empty?
        dealer_code = row[1]
        stock_code = row[4]
        marketing_name = row[3]
        vendor = row[5]
        model = row[6]
        device_type = row[7]
        catalog_price = row[8]
        fd_insured_value = row[10]
        fd_replacement_value = row[17]
        fd_koil_invoice_value = row[18]

        stl_insured_value = row[20]
        stl_replacement_value = row[27]
        stl_koil_invoice_value = row[28]

        yop_insured_value = row[30]
        yop_replacement_value = row[37]
        yop_fd_koil_invoice_value = row[38]

        prev_insured_value = row[40]
        prev_replacement_value = row[47]
        prev_fd_koil_invoice_value = row[48]

        puts "#{stock_code} @ #{catalog_price} - #{fd_koil_invoice_value} - #{prev_fd_koil_invoice_value}"
        # if Device.find_by_stock_code stock_code
        # end
        device = Device.find_by_stock_code stock_code
        if device.nil?
          # create a new one
          Device.create!({ 
            :dealer_code => dealer_code, :stock_code => stock_code, :marketing_name => marketing_name, :vendor => vendor,
            :model => model, :device_type => device_type, :catalog_price => catalog_price, :fd_insured_value => fd_insured_value,
            :fd_replacement_value => fd_replacement_value, :fd_koil_invoice_value => fd_koil_invoice_value, 
            :stl_insured_value => stl_insured_value, :stl_replacement_value => stl_replacement_value, :stl_koil_invoice_value => stl_koil_invoice_value,
            :prev_insured_value => prev_insured_value, :prev_replacement_value => prev_replacement_value, :prev_fd_koil_invoice_value => prev_fd_koil_invoice_value,
            :active => true})
        else
          # update everything apart from the model
          device.dealer_code = dealer_code
          device.stock_code = stock_code
          device.marketing_name = marketing_name
          device.vendor = vendor
          device.device_type = device_type
          device.catalog_price = catalog_price
          device.fd_insured_value = fd_insured_value
          device.fd_replacement_value = fd_replacement_value
          device.fd_koil_invoice_value = fd_koil_invoice_value
          device.stl_insured_value = stl_insured_value
          device.stl_replacement_value = stl_replacement_value
          device.stl_koil_invoice_value = stl_koil_invoice_value
          device.prev_insured_value = prev_insured_value
          device.prev_replacement_value = prev_replacement_value
          device.prev_fd_koil_invoice_value = prev_fd_koil_invoice_value
          device.active = true

          device.save! 
        end
      end
    end
  end

  # active_admin_importable do |model, hash|


  #   stock_code = (hash[:stock_code] if !hash[:stock_code].nil?)
  #   if !stock_code.nil?
  #     device = Device.find_by_stock_code stock_code

  #     if device.nil?
  #       device = Device.find_by_vendor_and_model(hash[:vendor], hash[:model])
  #       if device.nil?
  #         model.create!({
  #             :vendor => hash[:vendor],
  #             :marketing_name => hash[:marketing_name],
  #             :model => hash[:model],
  #             :stock_code => (hash[:stock_code] if !hash[:stock_code].nil?),
  #             :device_type => hash[:device_type],
  #             :catalog_price => hash[:catalog_price].gsub!(',','').to_f,
  #             :wholesale_price => hash[:wholesale_price].gsub!(',','').to_f,
  #             :fd_insured_value => hash[:fd_insured_value].gsub!(',','').to_f,
  #             :fd_replacement_value => hash[:fd_replacement_value].gsub!(',','').to_f,
  #             :fd_koil_invoice_value => hash[:fd_koil_invoice_value].gsub!(',','').to_f,
  #             :yop_insured_value => hash[:yop_insured_value].gsub!(',','').to_f,
  #             :yop_replacement_value => hash[:yop_replacement_value].gsub!(',','').to_f,
  #             :yop_fd_koil_invoice_value => hash[:yop_fd_koil_invoice_value].gsub!(',','').to_f,
  #             :prev_insured_value => hash[:prev_insured_value].gsub!(',','').to_f,
  #             :prev_replacement_value => hash[:prev_replacement_value].gsub!(',','').to_f,
  #             :prev_fd_koil_invoice_value => (hash[:prev_fd_koil_invoice_value].gsub!(',','').to_f if !hash[:prev_fd_koil_invoice_value].nil?),
  #             :version => ENV['CATALOG_VERSION']
  #         })
  #       else
  #         device.stock_code = stock_code
  #         device.device_type= hash[:device_type]
  #         device.catalog_price= hash[:catalog_price].gsub!(',','').to_f
  #         device.wholesale_price = hash[:wholesale_price].gsub!(',','').to_f
  #         device.fd_insured_value = hash[:fd_insured_value].gsub!(',','').to_f
  #         device.fd_replacement_value = hash[:fd_replacement_value].gsub!(',','').to_f
  #         device.fd_koil_invoice_value = hash[:fd_koil_invoice_value].gsub!(',','').to_f
  #         device.yop_insured_value = hash[:yop_insured_value].gsub!(',','').to_f
  #         device.yop_replacement_value = hash[:yop_replacement_value].gsub!(',','').to_f
  #         device.yop_fd_koil_invoice_value = hash[:yop_fd_koil_invoice_value].gsub!(',','').to_f
  #         device.prev_insured_value = hash[:prev_insured_value].gsub!(',','').to_f
  #         device.prev_replacement_value = hash[:prev_replacement_value].gsub!(',','').to_f
  #         device.prev_fd_koil_invoice_value = hash[:prev_fd_koil_invoice_value].gsub!(',','').to_f

  #         device.version = ENV['CATALOG_VERSION']
  #         device.save!
  #       end
  #     else
  #       #update the catalog
  #       device.model = hash[:model]
  #       device.marketing_name = hash[:marketing_name]
  #       device.vendor = hash[:vendor]
  #       device.device_type= hash[:device_type]
  #       device.catalog_price= hash[:catalog_price].gsub!(',','').to_f
  #       device.wholesale_price = hash[:wholesale_price].gsub!(',','').to_f
  #       device.fd_insured_value = hash[:fd_insured_value].gsub!(',','').to_f
  #       device.fd_replacement_value = hash[:fd_replacement_value].gsub!(',','').to_f
  #       device.fd_koil_invoice_value = hash[:fd_koil_invoice_value].gsub!(',','').to_f
  #       device.yop_insured_value = hash[:yop_insured_value].gsub!(',','').to_f
  #       device.yop_replacement_value = hash[:yop_replacement_value].gsub!(',','').to_f
  #       device.yop_fd_koil_invoice_value = hash[:yop_fd_koil_invoice_value].gsub!(',','').to_f
  #       device.prev_insured_value = hash[:prev_insured_value].gsub!(',','').to_f
  #       device.prev_replacement_value = hash[:prev_replacement_value].gsub!(',','').to_f
  #       device.prev_fd_koil_invoice_value = hash[:prev_fd_koil_invoice_value].gsub!(',','').to_f

  #       device.version = ENV['CATALOG_VERSION']
  #       device.save!
  #     end
  #   else
  #     model.create!({
  #          :vendor => hash[:vendor],
  #          :marketing_name => hash[:marketing_name],
  #          :model => hash[:model],
  #          :stock_code => (hash[:stock_code] if !hash[:stock_code].nil?),
  #          :device_type => hash[:device_type],
  #          :catalog_price => hash[:catalog_price].gsub!(',','').to_f,
  #          :wholesale_price => hash[:wholesale_price].gsub!(',','').to_f,
  #          :fd_insured_value => hash[:fd_insured_value].gsub!(',','').to_f,
  #          :fd_replacement_value => hash[:fd_replacement_value].gsub!(',','').to_f,
  #          :fd_koil_invoice_value => hash[:fd_koil_invoice_value].gsub!(',','').to_f,
  #          :yop_insured_value => hash[:yop_insured_value].gsub!(',','').to_f,
  #          :yop_replacement_value => hash[:yop_replacement_value].gsub!(',','').to_f,
  #          :yop_fd_koil_invoice_value => hash[:yop_fd_koil_invoice_value].gsub!(',','').to_f,
  #          :prev_insured_value => hash[:prev_insured_value].gsub!(',','').to_f,
  #          :prev_replacement_value => hash[:prev_replacement_value].gsub!(',','').to_f,
  #          :prev_fd_koil_invoice_value => (hash[:prev_fd_koil_invoice_value].gsub!(',','').to_f if !hash[:prev_fd_koil_invoice_value].nil?)
  #     })
  #   end
  # end

  filter :vendor
  filter :model
  filter :marketing_name
  filter :stock_code
  filter :active

  index do
    column :stock_code
    column :vendor
    column :model
    column :marketing_name
    column :dealer_code
    column :active
    column :device_type
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :stock_code
      f.input :vendor
      f.input :model
      f.input :marketing_name
      f.input :active
    end
    f.actions
  end

  show do |device|
    panel "Device Details" do
      attributes_table_for device, :vendor, :model, :marketing_name, :stock_code, :active
    end
  end

  actions :index, :edit, :update, :show
end
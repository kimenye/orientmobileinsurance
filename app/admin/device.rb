ActiveAdmin.register Device do

  controller do
    actions :all, :except => [:destroy]
  end

  menu :parent => "Reference Data"
  

  active_admin_import_anything do |file|
    doc = SimpleXlsxReader.open(file.tempfile)
        
    main_sheet = doc.sheets.first
    main_sheet.rows[2..main_sheet.rows.length].each do |row|
      if !row[0].nil? && !row[0].empty?
        dealer_code = row[1]
        stock_code = row[4].lstrip
        stock_code.rstrip!
        marketing_name = row[3].lstrip
        vendor = row[5]
        model = row[6]
        device_type = row[7]
        catalog_price = row[8]

        device = Device.find_by_stock_code stock_code
        if device.nil?
          # create a new one
          Device.create! :dealer_code => dealer_code, :stock_code => stock_code, :marketing_name => marketing_name, :vendor => vendor,
            :model => model, :device_type => device_type, :catalog_price => catalog_price, :active => true
        else
          # update everything apart from the model
          device.dealer_code = dealer_code
          device.stock_code = stock_code
          device.marketing_name = marketing_name
          device.vendor = vendor
          device.device_type = device_type
          device.catalog_price = catalog_price
          device.active = true

          device.save!
        end
      end
    end
  end

  filter :vendor
  filter :model
  filter :marketing_name
  filter :stock_code
  filter :active
  filter :dealer_code

  index do
    column :stock_code
    column :vendor
    column :model
    column :marketing_name
    column :dealer_code
    column :active
    column :device_type
    # default_actions
    actions defaults: true
  end

  form do |f|
    f.inputs "Details" do
      f.input :stock_code
      f.input :vendor
      f.input :model
      f.input :user_agent
      f.input :marketing_name
      f.input :active
      f.input :dealer_code
      if current_admin_user.is_admin
        f.input :catalog_price
      end
    end
    f.actions
  end

  show do |device|
    panel "Device Details" do
      attributes_table_for device, :vendor, :model, :marketing_name, :stock_code, :active, :dealer_code, :catalog_price, :user_agent
    end
  end
  # actions :index, :edit, :update, :show, :new
end
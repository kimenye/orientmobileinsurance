ActiveAdmin.register Device do

  controller do
    actions :all, :except => [:destroy]
  end

  menu :parent => "Reference Data"
  active_admin_importable do |model, hash|


    stock_code = (hash[:stock_code] if !hash[:stock_code].nil?)
    if !stock_code.nil?
      device = Device.find_by_stock_code stock_code

      if device.nil?
        device = Device.find_by_vendor_and_model(hash[:vendor], hash[:model])
        if device.nil?
          model.create!({
              :vendor => hash[:vendor],
              :marketing_name => hash[:marketing_name],
              :model => hash[:model],
              :stock_code => (hash[:stock_code] if !hash[:stock_code].nil?),
              :device_type => hash[:device_type],
              :catalog_price => hash[:catalog_price].gsub!(',','').to_f,
              :wholesale_price => hash[:wholesale_price].gsub!(',','').to_f,
              :fd_insured_value => hash[:fd_insured_value].gsub!(',','').to_f,
              :fd_replacement_value => hash[:fd_replacement_value].gsub!(',','').to_f,
              :fd_koil_invoice_value => hash[:fd_koil_invoice_value].gsub!(',','').to_f,
              :yop_insured_value => hash[:yop_insured_value].gsub!(',','').to_f,
              :yop_replacement_value => hash[:yop_replacement_value].gsub!(',','').to_f,
              :yop_fd_koil_invoice_value => hash[:yop_fd_koil_invoice_value].gsub!(',','').to_f,
              :prev_insured_value => hash[:prev_insured_value].gsub!(',','').to_f,
              :prev_replacement_value => hash[:prev_replacement_value].gsub!(',','').to_f,
              :prev_fd_koil_invoice_value => (hash[:prev_fd_koil_invoice_value].gsub!(',','').to_f if !hash[:prev_fd_koil_invoice_value].nil?),
              :version => ENV['CATALOG_VERSION']
          })
        else
          device.stock_code = stock_code
          device.device_type= hash[:device_type]
          device.catalog_price= hash[:catalog_price].gsub!(',','').to_f
          device.wholesale_price = hash[:wholesale_price].gsub!(',','').to_f
          device.fd_insured_value = hash[:fd_insured_value].gsub!(',','').to_f
          device.fd_replacement_value = hash[:fd_replacement_value].gsub!(',','').to_f
          device.fd_koil_invoice_value = hash[:fd_koil_invoice_value].gsub!(',','').to_f
          device.yop_insured_value = hash[:yop_insured_value].gsub!(',','').to_f
          device.yop_replacement_value = hash[:yop_replacement_value].gsub!(',','').to_f
          device.yop_fd_koil_invoice_value = hash[:yop_fd_koil_invoice_value].gsub!(',','').to_f
          device.prev_insured_value = hash[:prev_insured_value].gsub!(',','').to_f
          device.prev_replacement_value = hash[:prev_replacement_value].gsub!(',','').to_f
          device.prev_fd_koil_invoice_value = hash[:prev_fd_koil_invoice_value].gsub!(',','').to_f

          device.version = ENV['CATALOG_VERSION']
          device.save!
        end
      else
        #update the catalog
        device.model = hash[:model]
        device.marketing_name = hash[:marketing_name]
        device.vendor = hash[:vendor]
        device.device_type= hash[:device_type]
        device.catalog_price= hash[:catalog_price].gsub!(',','').to_f
        device.wholesale_price = hash[:wholesale_price].gsub!(',','').to_f
        device.fd_insured_value = hash[:fd_insured_value].gsub!(',','').to_f
        device.fd_replacement_value = hash[:fd_replacement_value].gsub!(',','').to_f
        device.fd_koil_invoice_value = hash[:fd_koil_invoice_value].gsub!(',','').to_f
        device.yop_insured_value = hash[:yop_insured_value].gsub!(',','').to_f
        device.yop_replacement_value = hash[:yop_replacement_value].gsub!(',','').to_f
        device.yop_fd_koil_invoice_value = hash[:yop_fd_koil_invoice_value].gsub!(',','').to_f
        device.prev_insured_value = hash[:prev_insured_value].gsub!(',','').to_f
        device.prev_replacement_value = hash[:prev_replacement_value].gsub!(',','').to_f
        device.prev_fd_koil_invoice_value = hash[:prev_fd_koil_invoice_value].gsub!(',','').to_f

        device.version = ENV['CATALOG_VERSION']
        device.save!
      end
    else
      model.create!({
           :vendor => hash[:vendor],
           :marketing_name => hash[:marketing_name],
           :model => hash[:model],
           :stock_code => (hash[:stock_code] if !hash[:stock_code].nil?),
           :device_type => hash[:device_type],
           :catalog_price => hash[:catalog_price].gsub!(',','').to_f,
           :wholesale_price => hash[:wholesale_price].gsub!(',','').to_f,
           :fd_insured_value => hash[:fd_insured_value].gsub!(',','').to_f,
           :fd_replacement_value => hash[:fd_replacement_value].gsub!(',','').to_f,
           :fd_koil_invoice_value => hash[:fd_koil_invoice_value].gsub!(',','').to_f,
           :yop_insured_value => hash[:yop_insured_value].gsub!(',','').to_f,
           :yop_replacement_value => hash[:yop_replacement_value].gsub!(',','').to_f,
           :yop_fd_koil_invoice_value => hash[:yop_fd_koil_invoice_value].gsub!(',','').to_f,
           :prev_insured_value => hash[:prev_insured_value].gsub!(',','').to_f,
           :prev_replacement_value => hash[:prev_replacement_value].gsub!(',','').to_f,
           :prev_fd_koil_invoice_value => (hash[:prev_fd_koil_invoice_value].gsub!(',','').to_f if !hash[:prev_fd_koil_invoice_value].nil?)
      })
    end
  end

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
    column "Retail Price", :catalog_price
    column :wholesale_price
    column :active
    default_actions
  end

  actions :index, :edit, :update, :show
end
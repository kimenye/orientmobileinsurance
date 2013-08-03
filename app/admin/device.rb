ActiveAdmin.register Device do
  menu :parent => "Reference Data"
  active_admin_importable do |model, hash|
    model.create!({
         :vendor => hash[:vendor],
         :marketing_name => hash[:marketing_name],
         :model => hash[:model],
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
         :prev_fd_koil_invoice_value => hash[:prev_fd_koil_invoice_value].gsub!(',','').to_f
     })
  end

  filter :vendor
  filter :model
  filter :marketing_name

  #index do
  #  column :vendor
  #  column :model
  #  column :marketing_name
  #  column "Retail Price", :catalog_price
  #  column :wholesale_price
  #  column "Insured Value (FD)", :fd_insured_value
  #  column "Replacement Value (FD)", :fd_replacement_value
  #end

  actions :index, :edit, :update

  #form do |f|
  #  f.inputs "Device Details" do
  #    f.input :vendor
  #    f.input :model
  #    f.input :marketing_name
  #    f.input :catalog_price
  #    f.input :wholesale_price
  #  end
  #  f.actions
  #end
end
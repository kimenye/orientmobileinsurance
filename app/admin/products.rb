ActiveAdmin.register Product do
  menu :parent => "Reference Data"
  
  active_admin_importable do |model,hash|
    # res = model.create! hash
    # check if the product exists by name
    if model.find_by_name(hash[:name]).nil?
      model.create! hash
    end

    product = Product.find_by_name hash[:name]    
    if ProductSerial.find_by_serial(hash[:serial]).nil?
        ProductSerial.create! :serial => hash[:serial], :product_id => product.id
    end
  
    # if it doesnt exist, we create

    # add the serial number to product serials if it doesnt exist 
  end
  filter :name
  filter :price

  index do
    column :name
    column :price, :sortable => :price do |product|
      div :class => "price" do
        number_to_currency product.price, :unit => "KES "
      end
    end   
    default_actions
  end
  
end



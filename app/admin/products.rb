ActiveAdmin.register Product do
  menu :parent => "Reference Data"
  active_admin_importable

  filter :name
  filter :price
  filter :serial

  index do
    column :name
    column :price, :sortable => :price do |product|
      div :class => "price" do
        number_to_currency product.price, :unit => "KES "
      end
    end
    column :serial    
    default_actions
  end
  
end

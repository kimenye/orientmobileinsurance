ActiveAdmin.register AdminUser do

  controller do
    actions :all, :except => [:destroy]
  end

  menu :parent => "Security"
  index do
    column :email                     
    column :current_sign_in_at        
    column :last_sign_in_at           
    column :sign_in_count
    column :is_admin
    default_actions                   
  end                                 

  filter :email
  filter :is_admin

  form do |f|                         
    f.inputs "Admin Details" do       
      f.input :email                  
      f.input :password               
      f.input :password_confirmation
      f.input :is_admin
    end                               
    f.actions                         
  end                                 
end                                   

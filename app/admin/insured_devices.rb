ActiveAdmin.register InsuredDevice do

  controller do
    actions :all, :except => [:edit, :destroy]
  end
  
end

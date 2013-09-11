ActiveAdmin.register Customer do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  actions  :index, :show, :edit, :update
end

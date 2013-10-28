ActiveAdmin.register InsuredDevice do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  actions :index, :show
end

ActiveAdmin.register InsuredDevice do

  index :title => "Insurable Devices"
  show :title => "Insurable Devices"

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  actions :index, :show
end

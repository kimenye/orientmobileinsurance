ActiveAdmin.register InsuredDevice do

  menu false

  controller do
    actions :all, :except => [:destroy]
  end

  form do |f|
    f.inputs "Insured Device Details" do
        f.input :imei
        f.input :phone_number
    end
    f.actions
  end

  actions :index, :show, :edit, :update
end

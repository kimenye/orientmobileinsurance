ActiveAdmin.register InsuredDevice do

  controller do
    actions :all, :except => [:destroy]
  end

  form do |f|
    f.inputs "Insured Device Details" do
        f.input :imei
    end
    f.actions
  end

  actions :index, :show, :edit, :update
end

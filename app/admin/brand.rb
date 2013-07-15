ActiveAdmin.register Brand do
  menu false
  index do
    column :name
  end

  form do |f|
    f.inputs "Brand Details" do
      f.input :name
    end
    f.actions
  end
end
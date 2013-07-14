ActiveAdmin.register User do
  index do
    column :name
    column :email
  end

  filter :name

  form do |f|
    f.inputs "User Details" do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
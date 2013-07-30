ActiveAdmin.register User do
  index do
    column :name
    column :email
    column :user_type
  end

  filter :name

  form do |f|
    f.inputs "User Details" do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :user_type, :collection => ["CP", "DP"]
      #f.input :agent, :collection => Agent.all.map(&:outlet)
      f.input :agent
    end
    f.actions
  end
end
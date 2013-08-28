ActiveAdmin.register User do
  menu :parent => "Security"
  index do
    column :name
    column :email
    column :username
    column :user_type
    default_actions
  end

  filter :name
  filter :user_type
  filter :email


  
  form do |f|
    f.inputs "User Details" do
      f.input :name
      f.input :email
      f.input :username
      f.input :password
      f.input :password_confirmation
      f.input :user_type, :collection => ["CP", "DP"]
      #f.input :agent, :collection => Agent.all.map(&:outlet)
      f.input :agent
    end
    f.actions
  end
end
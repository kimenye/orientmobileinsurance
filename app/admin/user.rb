ActiveAdmin.register User do

  controller do
    actions :all, :except => [:destroy]
  end

  menu :parent => "Security"
  index do
    column :name
    column :email
    column :username
    column :user_type
    # default_actions
    actions defaults: true
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
      f.input :user_type, :collection => ["CP", "DP", "SC"]
      #f.input :agent, :collection => Agent.all.map(&:outlet)
      f.input :agent
    end
    f.actions
  end
end
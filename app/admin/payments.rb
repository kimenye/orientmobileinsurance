ActiveAdmin.register Payment do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  index do
    column :amount
    column :method
    column :created_at
    column :reference
    column :for
    column :policy
    column :device
    column :customer
  end
  actions :index
end

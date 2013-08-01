ActiveAdmin.register Payment do
  index do
    column :amount
    column :method
    column :created_at
    column :reference
    column :for
    column :customer
  end
  actions :index
end

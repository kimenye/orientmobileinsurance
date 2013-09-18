ActiveAdmin.register Policy do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  #member_action :reset, :method => :put do

  index do
    column :policy_number
    column :customer
    column :start_date
    column :expiry
    column :status
    column "Premium", :premium
    column "Amount Paid", :amount_paid
    column :pending_amount
    column :minimum_paid
    column :minimum_due


    actions do |post|
      #link_to "Reset", reset_admin_policy_path(post), :class => "member_link", :method => :put
    end
  end
  actions :index, :show
end

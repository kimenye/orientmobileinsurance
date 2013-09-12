ActiveAdmin.register Policy do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  member_action :reset, :method => :put do

    policy = Policy.find(params[:id])
    id = policy.insured_device
    id.imei = nil
    id.save!

    policy.status = "Inactive"
    policy.start_date = nil
    policy.expiry = nil
    policy.save!

    redirect_to :action => :index
  end

  index do
    column :policy_number
    column :customer
    column :start_date
    column :expiry
    column :status
    column "Premium", :premium
    column "Amount Paid", :amount_paid
    column :pending_amount


    actions do |post|
      link_to "Reset", reset_admin_policy_path(post), :class => "member_link", :method => :put
    end
  end
  actions :index, :show
end

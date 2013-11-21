ActiveAdmin.register Enquiry do

  controller do
    actions :all, :except => [:edit, :destroy]

    def max_csv_records                                                          
      150_000                                                                    
    end
  end

  menu :parent => "Message"
  index do
    column "Phone Number" do |enquiry|
      link_to (enquiry.phone_number.nil?? "" : enquiry.phone_number), admin_enquiry_path(enquiry)
    end
    column :created_at
    column :url
    column :source
    column :sales_agent_code
    column :year_of_purchase
    column "Vendor (DA)", :vendor
    column "Model (DA)", :model
    column "Name (DA)", :marketing_name
    column "Detected", :detected
  end

  show do |enquiry|
    panel "Enquiry Details" do
      attributes_table_for enquiry, :phone_number, :source, :vendor, :model, :marketing_name, :url, :user_agent, :created_at, :updated_at
    end
  end

  filter :phone_number
  filter :year_of_purchase
  filter :vendor
  filter :model
  filter :marketing_name
  filter :created_at
  filter :sales_agent_code
  filter :source

  actions :index, :show
end
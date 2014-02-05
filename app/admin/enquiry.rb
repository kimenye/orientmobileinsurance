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

  collection_action :download_report, :method => :get do
    created_at_gte = params[:q][:created_at_gte]
    created_at_lte = params[:q][:created_at_lte]

    enquiries = Enquiry.all(:conditions => ["created_at >= ? AND created_at <= ? AND detected = ?",created_at_gte, created_at_lte, false])
    csv = CSV.generate( encoding: 'Windows-1251' ) do |csv|
      csv << ["Phone Number", "Date", "Vendor", "Model", "Device Name", "Year of Purchase"]

      enquiries.each do |enquiry|
        if !Device.find_by_vendor_and_model(enquiry.vendor, enquiry.model).nil?
          csv << [enquiry.phone_number, enquiry.created_at, enquiry.vendor, enquiry.model, enquiry.marketing_name, enquiry.year_of_purchase]
        end
      end
    end

    send_data csv.encode('Windows-1251'), type: 'text/csv; charset=windows-1251; header=present', disposition: "attachment; filename=report.csv"
  end

  action_item only: :index do
    link_to('Download Eligible Devices', params.merge(:action => :download_report))
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
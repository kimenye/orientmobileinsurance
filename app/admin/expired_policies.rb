ActiveAdmin.register_page "Expired Policies" do

  menu :label => "Expired Policies", :parent => "Simulator"

  page_action :reminders, :method => :post do

    service = ReminderService.new

    begin
      service.send_reminders
      redirect_to admin_simulator_path, :notice => "Reminders have been successfully sent"
    rescue
      redirect_to admin_simulator_path, :notice => "Reminder sending failed"
    end

  end

  content do

    columns do
      column do
        render "index"
      end
    end
  end

end
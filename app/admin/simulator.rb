ActiveAdmin.register_page "Simulator" do

  menu :parent => "Test"

  page_action :payment, :method => :post do
    puts ">>>> #{params}"
    #All payments are from MPESA
    #create a random transaction ref
    redirect_to admin_simulator_path, :notice => "Payment was successfully made"
  end

  page_action :sms, :method => :post do
    redirect_to admin_simulator_path, :notice => "SMS was successfully sent"
  end

  content do

    columns do
      column do
        render "index"
      end

      column do
        render "message"
      end
    end
  end

end
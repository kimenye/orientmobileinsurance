ActiveAdmin.register_page "Simulator" do

  #menu :parent => "Simulator"

  page_action :payment, :method => :post do
    puts ">>>> #{params}"
    #All payments are from MPESA
    #create a random transaction ref

    service = PaymentService.new

    channel = params["payment"]["channel"]
    account_id = params["payment"]["account_name"]
    amount = params["payment"]["amount"]
    transaction_ref = params["payment"]["transaction_ref"]


    result = service.handle_payment(account_id, amount, transaction_ref, channel)

    if result
      redirect_to admin_simulator_path, :notice => "Payment was successfully made"
    else
      redirect_to admin_simulator_path, :notice => "Payment failed"
    end

  end

  page_action :sms, :method => :post do

    text = params["sms"]["text"]
    mobile = params["sms"]["phone_number"]
    service = SmsService.new

    begin
      service.handle_sms_sending(text, mobile)
      redirect_to admin_simulator_path, :notice => "SMS was successfully sent"
    rescue
      redirect_to admin_simulator_path, :notice => "SMS sending failed"
    end

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
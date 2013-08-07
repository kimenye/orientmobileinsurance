namespace :data do
  desc "Cleans up the data in the database"
  task :clean_up => :environment do
    Payment.delete_all
    Claim.delete_all
    Policy.delete_all
    Quote.delete_all
    InsuredDevice.delete_all
    Customer.delete_all
    Enquiry.delete_all
    Message.delete_all
    Sms.delete_all
  end

  task :seed => :environment do
    enquiry = Enquiry.create! :source => "SMS", :phone_number => "254705866564", :hashed_phone_number => "abc"
    customer = Customer.create! :name => "Test Customer", :id_passport => "1234567890", :phone_number => "254705866564", :email => "trevor@kimenye.com"
    insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => Device.first.id, :imei => "123456789012345", :yop => 2013
    quote = Quote.create! :insured_device_id => insured_device.id, :insured_value => 1000, :premium_type => "Annual", :annual_premium => 300, :monthly_premium => 200, :account_name => "OMIXRY9832", :expiry_date => 3.days.from_now
    policy = Policy.create! :policy_number => "AAA/000", :quote_id => quote.id, :status => "Active", :start_date => Time.now, :expiry => 1.year.from_now
    payment = Payment.create! :method => "JP", :policy_id => policy.id, :amount => 300, :reference => "ABC"
  end

end

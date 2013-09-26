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
    enquiry = Enquiry.create! :source => "SMS", :phone_number => "254705866564", :hashed_phone_number => "abc", :hashed_timestamp => "def"
    customer = Customer.create! :name => "Test Customer", :id_passport => "1234567890", :phone_number => "254705866564", :email => "kimenye@gmail.com"
    insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => Device.first.id, :imei => "123456789012345", :yop => 2013
    quote = Quote.create! :insured_device_id => insured_device.id, :insured_value => 1000, :premium_type => "Annual", :annual_premium => 300, :monthly_premium => 200, :account_name => "OMIXRY9832", :expiry_date => 3.days.from_now, :agent_id => Agent.first.id
    policy = Policy.create! :policy_number => "AAA/000", :quote_id => quote.id, :status => "Active", :start_date => Time.now, :expiry => 1.year.from_now
    payment = Payment.create! :method => "JP", :policy_id => policy.id, :amount => 300, :reference => "ABC"
  end

  task :seed_claim => :environment do
    enquiry = Enquiry.create! :source => "SMS", :phone_number => "254705866564", :hashed_phone_number => "abc", :hashed_timestamp => "def"
    customer = Customer.create! :name => "Test Customer", :id_passport => "1234567890", :phone_number => "254705866564", :email => "trevor@kimenye.com"
    insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => Device.first.id, :imei => "123456789012345", :yop => 2013, :phone_number => "254705866564"
    quote = Quote.create! :insured_device_id => insured_device.id, :insured_value => 1000, :premium_type => "Annual", :annual_premium => 300, :monthly_premium => 200, :account_name => "OMIXRY9832", :expiry_date => 3.days.from_now, :agent_id => Agent.first.id
    policy = Policy.create! :policy_number => "AAA/000", :quote_id => quote.id, :status => "Active", :start_date => Time.now, :expiry => 1.year.from_now
    payment = Payment.create! :method => "JP", :policy_id => policy.id, :amount => 300, :reference => "ABC"

    claim = Claim.create! :policy_id => policy.id, :claim_type => "Loss / Theft", :contact_number => "254705866564", :police_abstract => true, :copy_id => true,
      :original_id => true, :blocking_request => true, :receipt => true, :agent_id => Agent.first.id, :incident_date => Time.now, :incident_description => "Phone stolen",
      :nearest_town => "Nairobi", :step => 2, :claim_no => "C/OMB/AAAA/0001"
  end

  task :map_users => :environment do
    users = User.all
    users.each do |user|
      if !user.agent.code.nil?
        user.username = user.agent.code
        user.save!
      end
    end
  end

  task :map_service_centers => :environment do
    users = User.all
    users.each do |user|
      if user.user_type != "SC" && user.user_type == "DP"
        sc_user = User.find_by_username("SC_#{user.username}")
        if sc_user.nil?
          service_agent = User.create! :name => user.name, :email => "sc_#{user.email}", :user_type => "SC", :agent_id => user.agent_id,
                                       :password => "kenyaorient", :password_confirmation => "kenyaorient", :username => "SC_#{user.username}"
        end
      end

    end
  end

  task :delete_devices => :environment do
    Device.delete_all
  end

  task :deprecate_devices => :environment do
    old_devices = Device.find_all_by_version (ENV['CATALOG_VERSION'].to_i - 1)
    old_devices.each do |device|
      device.active = false
      device.save!
    end
  end

  task :expire_leads => :environment do
    leads = Customer.where(:lead => true)
    leads.each do |l|
      if !l.is_a_lead?
        l.lead = false
        l.save!
      end
    end
  end

end

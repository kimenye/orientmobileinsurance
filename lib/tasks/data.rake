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
    insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => Device.find_by_vendor("Tecno").id, :imei => "123456789012345", :yop => 2013, :phone_number => "254705866564"
    quote = Quote.create! :insured_device_id => insured_device.id, :insured_value => 1000, :premium_type => "Annual", :annual_premium => 300, :monthly_premium => 200, :account_name => "OMIXRY9832", :expiry_date => 3.days.from_now, :agent_id => Agent.find_by_code("STL050").id
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

  task :seed_expiring_policy => :environment do
    enquiry = Enquiry.create! :source => "SMS", :phone_number => "254705866564", :hashed_phone_number => "abc", :hashed_timestamp => "def"
    customer = Customer.create! :name => "Test Customer", :id_passport => "1234567890", :phone_number => "254705866564", :email => "kimenye@gmail.com"
    insured_device = InsuredDevice.create! :customer_id => customer.id, :device_id => Device.first.id, :imei => "123456789012345", :yop => 2013, :phone_number => "254705866564"
    quote = Quote.create! :insured_device_id => insured_device.id, :insured_value => 1000, :premium_type => "Monthly", :annual_premium => 300, :monthly_premium => 100, :account_name => "OMIXRY9832", :expiry_date => 3.days.from_now, :agent_id => Agent.first.id
    policy = Policy.create! :policy_number => "AAA/000", :quote_id => quote.id, :status => "Active", :start_date => Time.now, :expiry => 2.hours.from_now
    payment = Payment.create! :method => "JP", :policy_id => policy.id, :amount => 100, :reference => "ABC"
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

  task :setup_admin => :environment do
    sa = AdminUser.find_by_email("omi@korient.co.ke")
    if !sa.nil?
      sa.is_admin = true
      sa.save!
    end
  end


  task :update_devices => :environment do
    update_file = "#{Rails.root}/doc/data/patches/#{ENV['UPDATE_FILE']}"
    puts "Update file: #{update_file}"
    devices = SmarterCSV.process(update_file)

    devices.each do |device|
      d = Device.find_by_stock_code(device[:stock_code])
      if !d.nil?
        d.prev_insured_value = device[:prev_insured_value]
        d.prev_replacement_value = device[:prev_replacement_value]
        d.prev_fd_koil_invoice_value = device[:prev_fd_koil_invoice_value]
        d.save!

        puts "Updated #{d.stock_code} : #{d.prev_insured_value}"
      end
    end
  end

  task :convert_catalogue => :environment do
    url = "#{Rails.root}/doc/data/patches/catalogue_october_15.xlsx"
    doc = SimpleXlsxReader.open(url)

    devices = []
    doc.sheets.first.rows[2..doc.sheets.first.rows.length].each do |row|
      devices << {
          :marketing_name => row[2],
          :stock_code => row[3],
          :vendor => row[4],
          :model => row[5],
          :device_type => row[6],
          :catalog_price => row[7],
          :wholesale_price => row[8],
          :fd_insured_value => row[10],
          :fd_replacement_value => row[17],
          :fd_koil_invoice_value => row[18],
          :yop_insured_value => row[20],
          :yop_replacement_value => row[27],
          :yop_fd_koil_invoice_value => row[28],
          :prev_insured_value => row[30],
          :prev_replacement_value => row[37],
          :prev_fd_koil_invoice_value => row[38]
      }
    end
  end

  task :send_reminders => :environment do
    service = ReminderService.new
    service.send_reminders
  end

  task :map_code => :environment do
    a = Agent.find_by_code("AG005064")
    a.tag = "FBANK"
    a.save!
  end

  task :create_dealers => :environment do
    fone_express = Dealer.create! :code => "FD", :name => "Fones Express"
    simba = Dealer.create! :code => "STL", :name => "Simba Telecom"
  end

  task :prepare_corporate_version => :environment do

    Customer.all.each do |c|
      c.customer_type = "Invidual" if c.customer_type.nil?
      c.phone_number = c.insured_devices.first.phone_number if c.phone_number.nil?
      c.save!
    end

    # map all payments to a quote
    Payment.all.each do |payment|
      payment.quote_id = payment.policy.quote_id if !payment.policy.nil?
      payment.save!
    end

    # add a customer to every quote
    Quote.all.each do |quote|
      quote.customer_id = quote.insured_device.customer_id if !quote.insured_device.nil?
      quote.quote_type = "Individual" if quote.quote_type.nil?
      quote.save!
    end

    # set the premium and replacement values for all devices
    InsuredDevice.all.each do |id|
      quote = Quote.find_by_insured_device_id(id)
      id.quote_id = quote.id if !quote.nil?
      id.insurance_value = id.quote.insured_value if !id.quote.nil?
      id.premium_value = id.quote.amount_due if !id.quote.nil?
      id.save!
    end

    Policy.all.each do |p|
      id = InsuredDevice.find_by_quote_id(p.quote_id)
      p.insured_device_id = id.id
      p.save!
    end

  end
end

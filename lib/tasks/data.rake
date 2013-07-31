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
  end

end

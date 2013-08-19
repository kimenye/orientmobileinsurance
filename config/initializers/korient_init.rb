require 'rufus/scheduler'

if Rails.env.production?

  timer = Rufus::Scheduler.start_new
  timer.cron '0 9 * * *' do
  #  Check for payments that havent been payed (1 yr premium)
  #  Check for payments that need to be made 2 days before they need to be payed (monthly installments)


  end
end
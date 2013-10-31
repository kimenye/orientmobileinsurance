require 'rufus/scheduler'

#if Rails.env.production?

  timer = Rufus::Scheduler.start_new
  puts "Setting up scheduler"
  service = ReminderService.new
  timer.cron '55 8 * * *' do
    puts "Processing reminders for #{Time.now}"
    service.send_reminders
  end
#end

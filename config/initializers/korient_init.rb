require 'rufus/scheduler'

if Rails.env.production?

  timer = Rufus::Scheduler.start_new
  service = ReminderService.new
  timer.cron '55 8 * * *' do

    service.send_reminders

  end
end

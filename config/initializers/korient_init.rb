require 'rufus/scheduler'

#if Rails.env.production?

  timer = Rufus::Scheduler.start_new
  Rails.logger.info "Setting up scheduler"
  timer.cron '55 8 * * *' do
    Rails.logger.info "Processing reminders for #{Time.now}"
    ReminderService.send_reminders
  end
#end

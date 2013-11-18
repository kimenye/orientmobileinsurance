require 'rufus/scheduler'

#if Rails.env.production?

  timer = Rufus::Scheduler.start_new
  Rails.logger.info "Setting up scheduler"
  service = ReminderService.new
  timer.cron '55 8 * * *' do
    Rails.logger.info "Processing reminders for #{Time.now}"
    service.send_reminders
  end
#end

ActionMailer::Base.smtp_settings = {
    :port =>           587,
    :address =>        'smtp.mandrillapp.com',
    :user_name =>      ENV['MANDRILL_USERNAME'],
    :password =>       ENV['MANDRILL_APIKEY'],
    :domain =>         'heroku.com',
    :authentication => 'plain',
    :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = "localhost:3000"
ActionMailer::Base.delivery_method = :smtp
#Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?

require 'httparty'
class SmppClient
  
  def self.send to, message
    url = ENV['SMPP_URL']
    username = ENV['SMPP_USERNAME']
    password = ENV['SMPP_PASSWORD']

    to = "+#{to}" if ! to.start_with? ("+")

    url = "#{url}?username=#{username}&password=#{password}&to=#{to}&text=#{message}"
    # curl "http://127.0.0.1:13013/cgi-bin/sendsms?username=kannel&password=p@ssw0rd&to=+254705866564&text=Again"  
    
    success = true
    if Rails.env.production?
      response = HTTParty.get(url)
      # 0: Accepted for delivery
      success =response.body == "0: Accepted for delivery"
    end
    success
  end
end
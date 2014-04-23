class Sms < ActiveRecord::Base
  attr_accessible :text, :to, :request, :response, :receipt_id, :delivered, :time_of_delivery
end

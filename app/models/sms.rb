class Sms < ActiveRecord::Base
  attr_accessible :text, :to, :request, :response, :receipt_id, :delivered
end

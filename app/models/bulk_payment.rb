class BulkPayment < ActiveRecord::Base
  attr_accessible :amount_paid, :amount_required, :channel, :code, :reference, :email, :phone_number

  validates :code, uniqueness: :true  
end

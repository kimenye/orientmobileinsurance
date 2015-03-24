# == Schema Information
#
# Table name: bulk_payments
#
#  id              :integer          not null, primary key
#  code            :string(255)
#  reference       :string(255)
#  amount_required :decimal(, )
#  amount_paid     :decimal(, )
#  channel         :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  email           :string(255)
#  phone_number    :string(255)
#

class BulkPayment < ActiveRecord::Base
  attr_accessible :amount_paid, :amount_required, :channel, :code, :reference, :email, :phone_number

  validates :code, uniqueness: :true  
end

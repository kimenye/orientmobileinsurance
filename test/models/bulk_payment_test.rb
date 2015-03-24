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

require "test_helper"

class BulkPaymentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

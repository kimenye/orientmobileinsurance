# == Schema Information
#
# Table name: policies
#
#  id                :integer          not null, primary key
#  quote_id          :integer
#  status            :string(255)
#  policy_number     :string(255)
#  start_date        :datetime
#  expiry            :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  insured_device_id :integer
#

require 'test_helper'

class PolicyTest < ActiveSupport::TestCase

  before do
    @new_policy = Policy.new ({
        :start_date => Time.now,
        :expiry => 365.days.from_now
    })

    @old_policy = Policy.new({
        :start_date => 22.days.ago,
        :expiry => (365-22).days.from_now
    })

    @expired_policy = Policy.new({
        :start_date => 300.days.ago,
        :expiry => (1).days.ago
    })
  end

  test "A customer cannot make a claim before 21 days after the policy starts" do
    can_claim = @new_policy.is_open_for_claim
    assert_equal can_claim, false, "Cannot claim on policy made today"
  end

  test "A customer can only make a claim after 21 days" do
    can_claim = @old_policy.is_open_for_claim
    assert_equal can_claim, true, "Can claim on policy made 22 days ago"
    end

  test "A customer can only policies that have not expired" do
    can_claim = @expired_policy.is_open_for_claim
    assert_equal can_claim, false, "Cannot claim on expired policies"
  end

end

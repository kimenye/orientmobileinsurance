require 'test_helper'
class ReminderServiceTest < ActiveSupport::TestCase

  test 'It can get a tell which policies are due to expire in a given period' do
    before = ReminderService.get_policies_expiring_in_duration(2).count
    assert_equal 0, before

    two_days = Policy.create! expiry: 2.days.from_now, insured_device_id: insured_devices(:insured_apple).id
    after = ReminderService.get_policies_expiring_in_duration(2).count
    assert_equal 1, after
  end

  test 'It expired policies that have lapsed' do
    yesterday = Policy.create! expiry: 1.days.ago, insured_device_id: insured_devices(:insured_apple).id, status: 'Active'

    ReminderService.expire_lapsed_policies!

    yesterday.reload
    assert_equal 'Expired', yesterday.status
  end
end
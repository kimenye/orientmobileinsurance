# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  	test "A subscription must have an email address" do
		Subscription.delete_all
		@new = Subscription.new :email => nil		
		assert_equal false, @new.valid?
	end

  	test "A subscription must have a valid email address" do
		Subscription.delete_all
		@new = Subscription.new :email => "sasa"		
		assert_equal false, @new.valid?

		@new = Subscription.new :email => "sasa@sasa.com"		
		assert_equal true, @new.valid?
	end

  	test "A subscription must have a unique email address" do
		Subscription.delete_all
		@subscription = Subscription.create! :email => "me@you.com"	
		@new = Subscription.new :email => "me@you.com"	

		assert_equal false, @new.valid?
	end
end

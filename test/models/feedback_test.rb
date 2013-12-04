require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  	test "Feedback must have an email address, name and message" do
		Feedback.delete_all
		@new = Feedback.new :email => nil, :name => "sdfs@you.com", :message => "sdfds"		
		assert_equal false, @new.valid?

		@new = Feedback.new :email => "sdfsd@sd.com", :name => nil, :message => "sdfds"		
		assert_equal false, @new.valid?

		@new = Feedback.new :email => "sdfsd@sd.com", :name => "sdfds", :message => nil		
		assert_equal false, @new.valid?

		@new = Feedback.new :email => "sdfsd@sd.com", :name => "sdfds", :message => "hello"		
		assert_equal true, @new.valid?
	end

  	test "Feedback must have a valid email address" do
		
		@new = Feedback.new :email => "sasa", :name => "sdfdsf", :message => "Wwosaa"		
		assert_equal false, @new.valid?

		@new = Feedback.new :email => "sasa@sasa.com", :name => "sdfdsf", :message => "Wwosaa"		
		assert_equal true, @new.valid?
	end
end

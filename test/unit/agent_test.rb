# == Schema Information
#
# Table name: agents
#
#  id           :integer          not null, primary key
#  town         :string(255)
#  brand        :string(255)
#  outlet       :string(255)
#  location     :string(255)
#  code         :string(255)
#  email        :string(255)
#  phone_number :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  outlet_name  :string(255)
#  tag          :string(255)
#  discount     :float
#

require 'test_helper'
class AgentTest < ActiveSupport::TestCase

	test "An agent is in the STL network if their code starts with STL" do		
		a = Agent.new ({:brand => "Simba Telecom", :code => "STL005"})
		assert_equal true, a.is_stl
		assert_equal false, a.is_fd
	end

	test "An agent is in the FD network if their code if an fxp code" do
		a = Agent.new ({:brand => "Woosah", :code => "FXP000"})
		assert_equal true, a.is_fd
		assert_equal false, a.is_stl

		a.code = "AG0000"
		assert_equal false, a.is_fd
		assert_equal false, a.is_stl
		assert_equal true, a.is_neither_fd_nor_stl 
	end
end

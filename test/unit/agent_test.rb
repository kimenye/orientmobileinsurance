require 'test_helper'
class AgentTest < ActiveSupport::TestCase

	test "An agent is in the STL network if their code starts with STL" do
		
		a = Agent.new ({:brand => "Simba Telecom", :code => "STL005"})
		assert_equal true, a.is_stl
	end

end
require 'test_helper'

class ClaimServiceTest < ActiveSupport::TestCase
	test "The claim number should get the last claim in saved and add 1 to the index" do
		service = ClaimService.new

		Claim.delete_all
		Claim.create! :claim_type => "Theft", :claim_no => "C/OMB/AAAA/0023"

		claim_no = service.create_claim_no 
		assert_equal "C/OMB/AAAA/0024", claim_no
	end

	test "A claim number should be unique in the system" do
		Claim.delete_all
		Claim.create! :claim_type => "Theft", :claim_no => "C/OMB/AAAA/0023"

		c = Claim.new :claim_type => "Damage",  :claim_no => "C/OMB/AAAA/0023"
		assert_equal false, c.valid?
	end

#	test "A claim number should not have lowercase charachters" do
#		claim = Claim.new :claim_type => "Damage", :claim_no => "C/OMB/aaa/0023"
#	end
end
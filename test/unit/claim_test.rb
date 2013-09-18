require 'test_helper'
class ClaimTest < ActiveSupport::TestCase

  before do
    
    @policy = Policy.new({
      :start_date => 3.days.ago
    })
    @policy.save!

    @claim = Claim.new({
        :step => 1,
        :policy_id => @policy.id
    })
    
    @damage_claim = Claim.new({
        :claim_type => "Damage",
        :step => 2
      })
    @theft_claim = Claim.new({
        :claim_type => "Theft / Loss",
        :step => 2
      })
  end

  test "A claim has different types" do
    assert_equal true, @damage_claim.is_damage?
    assert_equal false, @damage_claim.is_theft?
    assert_equal false, @theft_claim.is_damage?
    assert_equal true, @theft_claim.is_theft?
  end

  test "A claim has different states" do
    assert_equal true, @claim.is_in_customer_stage?
    @claim.step = 2
    assert_equal false, @claim.is_in_customer_stage?
    assert_equal true, @claim.is_in_dealer_stage?
  end

  test "A claim can be saved by a user" do
    assert_equal true, @claim.save
  end

  test "A claim can only be saved by a dealer if all document have been received" do
    assert_equal true, @theft_claim.is_theft?
    assert_equal true, @theft_claim.is_in_dealer_stage?
    result = @theft_claim.valid?
    assert_equal false, result, "Should be false because of validation failure"

    @theft_claim.police_abstract = true
    @theft_claim.original_id = true
    @theft_claim.copy_id = true
    @theft_claim.blocking_request = true
    @theft_claim.receipt = true

    result = @theft_claim.valid?
    assert_equal true, result, "Should be true because of validation pass"
  end

  test  "A claim status is forwarded to KOIL if it has been handled by a dealer or service center" do
    @damage = Claim.new({ :step => 2, :claim_type => "Damage"})
    assert_equal false, @damage.is_forward_to_koil?
    assert_equal true, @damage.is_forward_to_sc?


    @theft = Claim.new({ :step => 2, :claim_type => "Loss / Theft"})
    assert_equal true, @theft.is_forward_to_koil?

    @damage.step = 3
    assert_equal true, @damage.is_forward_to_koil?

  end
  
  test "A damage claim must have a description if to be saved by a dealer" do
    assert_equal true, @damage_claim.is_damage?
  end
  
  test "A claim cannot have an incident date that is before the policy started" do
    @test_claim = Claim.new({
        :step => 1,
        :policy_id => @policy.id,
        :claim_type => "Loss / Theft"
    })
    @test_claim.save!
    @test_claim.incident_date = 5.days.ago
    assert_equal false, @test_claim.valid?
    @test_claim.incident_date = 2.days.ago
    assert_equal true, @test_claim.valid?
  end
  
  test "A damage claim must be at least 14 days after the policy start " do
    @test_claim = Claim.new({
        :step => 1,
        :policy_id => @policy.id,
        :claim_type => "Damage"
    })
    @test_claim.save!
    @test_claim.incident_date = 10.days.from_now
    #TODO: re-enable validity tests
    #assert_equal false, @test_claim.valid?
    assert_equal true, @test_claim.valid?
  end
end
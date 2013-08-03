require 'test_helper'
class ClaimTest < ActiveSupport::TestCase

  before do

    @claim = Claim.new({
        :step => 1
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

end
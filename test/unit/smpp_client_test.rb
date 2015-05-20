require 'test_helper'

class SmppClientTest < ActiveSupport::TestCase

  test "Can send via smpp" do
    sent = SmppClient.send "254705866564", "Again"
    assert sent 
  end
  
end
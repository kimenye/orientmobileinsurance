require "test_helper"

class ApplicationControllerTest < ActionController::TestCase

  test 'the model for a non ios device is returned as is' do
    data = {
        "osIOs" => false,
        "model" => "GT-I9000"
    }

    assert_equal 'GT-I9000', @controller.send(:get_model_name,data)
  end

  test 'If iOS is greater than 5, it must be either an iPhone4,iPhone5,iPhone4s or greater ' do
    data = {
        "osIOs" => true,
        "model" => "iPhone",
        "osVersion" => "4_1"
    }

    assert_equal 'iPhone', @controller.send(:get_model_name,data)
  end

  test 'If devicePixel ratio > 2 and device.availHeight = 538 then it its an iphone5 or higher' do
    data = {
        "osIOs" => true,
        "model" => "iPhone",
        "osVersion" => "6_1",
        "device.availHeight" => "548",
        "device.devicePixelRatio" => "2",
        "isMobilePhone" => true
    }

    assert_equal 'iPhone 5', @controller.send(:get_model_name,data)
  end
end

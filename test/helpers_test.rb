require File.expand_path '../test_helper', __FILE__

class HelperTest
  attr_accessor :request
  include Rack::Recaptcha::Helpers

  def initialize
    @request = HelperTest::Request.new
  end

  class Request
    attr_accessor :env
  end
end

# With "attr_accessor :request" HelperTest has "request" defined as a method
# even when @request is set to nil
#
# defined?(request)
# => method
# request
# => nil
# self
# => #<HelperTest:0x00000002125000 @request=nil>
class HelperTestWithoutRequest
  include Rack::Recaptcha::Helpers
end

describe Rack::Recaptcha::Helpers do

  def helper_test
    HelperTest.new
  end

  def helper_test_without_request
    HelperTestWithoutRequest.new
  end

  before do
    Rack::Recaptcha.public_key = ::PUBLIC_KEY
  end

  describe ".recaptcha_widget" do

    it "should render recaptcha div" do
      topic = helper_test.recaptcha_widget()

      assert_match %r{<div class="g-recaptcha" data-sitekey=".*"></div>}, topic
    end

    it "should use given public key" do
      topic = helper_test.recaptcha_widget(:public_key => 'test')

      assert_match %r{<div class="g-recaptcha" data-sitekey="test"></div>}, topic
    end
  end

  describe ".recaptcha_valid?" do
    it "should assert that it passes when recaptcha.valid is true" do
      Rack::Recaptcha.test_mode = nil
      mock(helper_test.request.env).[]('recaptcha.valid').returns(true)
      assert helper_test.recaptcha_valid?
    end

    it "should refute that it passes when recaptcha.valid is false" do
      Rack::Recaptcha.test_mode = nil
      mock(helper_test.request.env).[]('recaptcha.valid').returns(false)
      refute helper_test.recaptcha_valid?
    end

    it "should assert that it passes when test mode set to pass" do
      Rack::Recaptcha.test_mode!
      assert helper_test.recaptcha_valid?
    end

    it "should assert that it passes when test mode set to fail" do
      Rack::Recaptcha.test_mode! :return => false
      refute helper_test.recaptcha_valid?
    end
  end

  describe ".recaptcha_widget without request object" do

    it "should work without request object" do
      topic = helper_test_without_request.recaptcha_widget()

      assert_match %r{<div class="g-recaptcha" data-sitekey=".*"></div>},            topic
    end

  end

end

require File.expand_path '../test_helper', __FILE__

describe Rack::Recaptcha do
  before do
    FakeWeb.allow_net_connect = false
  end

  describe "#test_mode!" do
    it "should set test_mode to true" do
      Rack::Recaptcha.test_mode!
      assert Rack::Recaptcha.test_mode
    end

    it "should set test_mode to true" do
      Rack::Recaptcha.test_mode! :return => false
      refute Rack::Recaptcha.test_mode
    end
  end

  it "should hit the login and pass" do
    FakeWeb.register_uri(:post, Rack::Recaptcha::VERIFY_URL, :body => '{"success":true}')
    post("/login", 'g-recaptcha-response' => 'response')
    assert_equal 'post login', last_response.body
  end

  it "should hit the login and fail" do
    FakeWeb.register_uri(:post, Rack::Recaptcha::VERIFY_URL, :body => '{"success":false,"error-codes":["invalid-input-response"]}')
    post("/login", 'g-recaptcha-response' => 'response')
    assert_equal 'post fail', last_response.body
  end
end

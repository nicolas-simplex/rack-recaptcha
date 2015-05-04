require  File.expand_path '../recaptcha/helpers', __FILE__
require 'net/http'
require 'json'

module Rack
  class Recaptcha
    API_URL         = 'http://www.google.com/recaptcha/api.js'
    API_SECURE_URL  = 'https://www.google.com/recaptcha/api.js'
    VERIFY_URL      = 'https://www.google.com/recaptcha/api/siteverify'
    RESPONSE_FIELD  = 'g-recaptcha-response'

    class << self
      attr_accessor :private_key, :public_key, :test_mode, :proxy_host, :proxy_port, :proxy_user, :proxy_password

      def test_mode!(options = {})
        value = options[:return]
        self.test_mode = value.nil? ? true : options[:return]
      end
    end

    # Initialize the Rack Middleware. Some of the available options are:
    #   :public_key  -- your ReCaptcha API public key *(required)*
    #   :private_key -- your ReCaptcha API private key *(required)*
    #
    def initialize(app,options = {})
      @app = app
      @paths = options[:paths] && [options[:paths]].flatten.compact
      self.class.private_key = options[:private_key]
      self.class.public_key = options[:public_key]
      self.class.proxy_host = options[:proxy_host]
      self.class.proxy_port = options[:proxy_port]
      self.class.proxy_user = options[:proxy_user]
      self.class.proxy_password = options[:proxy_password]
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      request = Request.new(env)
      if request.params[RESPONSE_FIELD]
        value, msg = verify(
          request.ip,
          request.params[RESPONSE_FIELD]
        )
        env.merge!('recaptcha.valid' => value, 'recaptcha.msg' => msg)
      end
      @app.call(env)
    end

    def verify(ip, response)
      params = {
        'secret' => Rack::Recaptcha.private_key,
        'remoteip'   => ip,
        'response'   => response
      }

      uri  = URI.parse(VERIFY_URL)


      if self.class.proxy_host && self.class.proxy_port
        http = Net::HTTP.Proxy(self.class.proxy_host,
                               self.class.proxy_port,
                               self.class.proxy_user,
                               self.class.proxy_password).start(uri.host, uri.port, :use_ssl => true)
      else
        http = Net::HTTP.start(uri.host, uri.port, :use_ssl => true)
      end

      request           = Net::HTTP::Post.new(uri.path)
      request.form_data = params
      response          = http.request(request)

      parsed_response = JSON.parse(response.body)
      success = parsed_response['success']
      error_messages = parsed_response['error-codes'] || []
      return [success, error_messages.join(',')]
    end

  end
end

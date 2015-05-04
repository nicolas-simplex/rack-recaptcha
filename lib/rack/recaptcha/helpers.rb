require 'json'

module Rack
  class Recaptcha
    module Helpers

      DEFAULT= {
        :ssl => true
      }

      # Helper method to output a recaptcha widget.
      # Available options:
      #
      #  :public_key - Set the public key. Overrides the key set in Middleware option
      def recaptcha_widget(options={})
        options = DEFAULT.merge(options)
        options[:public_key] ||= Rack::Recaptcha.public_key

        %{<div class="g-recaptcha" data-sitekey="#{options[:public_key]}"></div>}.gsub(/^ +/, '')
      end

      # Helper method to output the recaptcha javascript.
      # Available options:
      #
      #  :language   - Set the language
      def recaptcha_javascript(options={})
        options = DEFAULT.merge(options)
        path = options[:ssl] ? Rack::Recaptcha::API_SECURE_URL : Rack::Recaptcha::API_URL
        params = ''
        params += "?hl=" + uri_parser.escape(options[:language].to_s) if options[:language]
        %{<script src='#{path + params}'></script>}
      end

      # Helper to return whether the recaptcha was accepted.
      def recaptcha_valid?
        test = Rack::Recaptcha.test_mode
        test.nil? ? request.env['recaptcha.valid'] : test
      end

      private

      def uri_parser
        @uri_parser ||= URI.const_defined?(:Parser) ? URI::Parser.new : URI
      end

    end
  end
end

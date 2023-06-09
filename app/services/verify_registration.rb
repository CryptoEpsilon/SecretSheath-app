# frozen_string_literal: true

require 'http'

module SecretSheath
  # Returns an authenticated user, or nil
  class VerifyRegistration
    class VerificationError < StandardError; end
    class ApiServerError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(registration_data)
      regis_req = registration_data.to_h
      registration_token = SecureMessage.encrypt(regis_req)
      regis_req['verification_url'] = "#{@config.APP_URL}/auth/register/#{registration_token}"

      response = HTTP.post("#{@config.API_URL}/auth/register",
                           json: SignedMessage.sign(regis_req))

      raise(VerificationError) unless response.code == 202

      JSON.parse(response.to_s)
    rescue HTTP::ConnectionError
      raise(ApiServerError)
    end
  end
end

# frozen_string_literal: true

require 'http'

module SecretSheath
  # Create a new configuration file for a project
  class CreateNewKey
    # Error for when the API returns a non-201 HTTP code
    class DuplicateKeyError < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, folder_name:, key_data:)
      config_url = "#{api_url}/keys/#{folder_name}"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post(config_url, json: key_data)
      raise DuplicateKeyError if response.code == 409

      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end

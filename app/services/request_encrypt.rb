# frozen_string_literal: true

require 'http'

module SecretSheath
  # Create a new configuration file for a project
  class RequestEncrypt
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, folder_name:, key_alias:, plaintext_data:)
      config_url = "#{api_url}/encrypt/#{folder_name}/#{key_alias}"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post(config_url, json: plaintext_data)
      response.code == 200 ? JSON.parse(response.body.to_s) : raise
    end
  end
end

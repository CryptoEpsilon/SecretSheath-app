# frozen_string_literal: true

require 'http'

module SecretSheath
  # Create a new configuration file for a project
  class AddAccessor
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, folder_name:, key_alias:, accessor:)
      config_url = "#{api_url}/keys/#{folder_name}/#{key_alias}/accessors"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .put(config_url, json: accessor)

      response.code == 201 ? response.body.to_s : raise
    end
  end
end

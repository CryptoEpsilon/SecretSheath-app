# frozen_string_literal: true

require 'http'

module SecretSheath
  # Create a new configuration file for a folder
  class CreateNewFolder
    # Error for when the API returns a non-201 HTTP code
    class DuplicateFolderError < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, folder_data:)
      config_url = "#{api_url}/folders"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post(config_url, json: folder_data)

      raise DuplicateFolderError if response.code == 409

      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end

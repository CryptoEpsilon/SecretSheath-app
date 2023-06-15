# frozen_string_literal: true

require 'http'

module SecretSheath
  # Returns all folders belonging to an account
  class GetKey
    def initialize(config)
      @config = config
    end

    def call(current_account, folder_name, key_alias)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/keys/#{folder_name}/#{key_alias}")

      response.code == 200 ? response.body.to_s : nil
    end
  end
end

# frozen_string_literal: true

require 'http'

module SecretSheath
  # Returns all folders belonging to an account
  class DeleteKey
    def initialize(config)
      @config = config
    end

    def call(current_account, folder_name, key_alias)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .delete("#{@config.API_URL}/keys/#{folder_name}/#{key_alias}")

      response.code == 200 ? JSON.parse(response.body.to_s) : raise
    end
  end
end

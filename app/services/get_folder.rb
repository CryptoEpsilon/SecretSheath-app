# frozen_string_literal: true

require 'http'

module SecretSheath
  # Returns all folders belonging to an account
  class GetFolder
    def initialize(config)
      @config = config
    end

    def call(current_account, folder_name)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/folders/#{folder_name}")

      response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
    end
  end
end

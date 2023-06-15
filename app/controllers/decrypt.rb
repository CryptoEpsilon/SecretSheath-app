# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class App < Roda
    route('decrypt') do |routing|
      routing.on String, String do |folder_name, key_alias|
        raise Account::AuthorizationError unless @current_account.logged_in?

        @decrypt_route = "/decrypt/#{folder_name}/#{key_alias}"

        # POST /decrypt/[folder_name]/[key_alias]
        routing.post do
          req_body = JSON.parse(routing.body.read, symbolize_names: true)
          ciphertext_data = Form::DecryptForm.new.call(req_body)

          routing.halt 400, { error: 'Bad Request' } if ciphertext_data.failure?

          RequestDecrypt.new(App.config).call(
            current_account: @current_account,
            folder_name:,
            key_alias:,
            ciphertext_data: ciphertext_data.to_h
          )
        rescue Account::AuthorizationError => e
          puts "FAILURE Decrypt cipher: #{e.inspect}"
          puts e.backtrace
          routing.halt 401, { message: 'Unauthorized' }.to_json
        rescue RequestDecrypt::DecryptError => e
          puts "FAILURE Decrypt cipher: #{e.inspect}"
          routing.halt 400, { message: 'Bad Request' }.to_json
        rescue StandardError => e
          puts "FAILURE Decrypt cipher: #{e.inspect}"
          puts e.backtrace
          routing.halt 500, { message: 'Internal Server Error' }.to_json
        end
      end
    end
  end
end

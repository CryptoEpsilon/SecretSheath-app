# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class App < Roda
    route('encrypt') do |routing|
      routing.on String, String do |folder_name, key_alias|
        raise Account::AuthorizationError unless @current_account.logged_in?

        @encrypt_route = "/encrypt/#{folder_name}/#{key_alias}"

        # POST /encrypt/[folder_name]/[key_alias]
        routing.post do
          req_body = JSON.parse(routing.body.read, symbolize_names: true)
          plaintext_data = Form::EncryptForm.new.call(req_body)

          routing.halt 400, { error: 'Bad Request' }.to_json if plaintext_data.failure?

          RequestEncrypt.new(App.config).call(
            current_account: @current_account,
            folder_name:,
            key_alias:,
            plaintext_data: plaintext_data.to_h
          )
        rescue Account::AuthorizationError => e
          puts "FAILURE Creating key: #{e.inspect}"
          puts e.backtrace
          routing.halt 401, { message: 'Unauthorized' }.to_json
        rescue StandardError => e
          puts "FAILURE Creating key: #{e.inspect}"
          puts e.backtrace
          routing.halt 500, { message: 'Internal Server Error' }.to_json
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class App < Roda
    route('encrypt') do |routing|
      routing.on String, String do |folder_name, key_alias|
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @encrypt_route = "/encrypt/#{folder_name}/#{key_alias}"

        # POST /encrypt/[folder_name]/[key_alias]
        routing.post do
          plaintext_data = Form::EncryptForm.new.call(routing.params)

          if plaintext_data.failure?
            flash[:error] = Form.message_values(plaintext_data)
            routing.halt
          end
          enc_res = RequestEncrypt.new(App.config).call(
            current_account: @current_account,
            folder_name:,
            key_alias:,
            plaintext_data: plaintext_data.to_h
          )
          flash[:notice] = "Ciphertext: #{enc_res['data']['attributes']['ciphertext']}"
        rescue StandardError => e
          puts "FAILURE Creating key: #{e.inspect}"
          puts e.backtrace
          flash[:error] = 'Could not process plaintext'
        ensure
          routing.redirect "/folders/#{folder_name}"
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class App < Roda
    route('decrypt') do |routing|
      routing.on String, String do |folder_name, key_alias|
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @decrypt_route = "/decrypt/#{folder_name}/#{key_alias}"

        # POST /decrypt/[folder_name]/[key_alias]
        routing.post do
          ciphertext_data = Form::DecryptForm.new.call(routing.params)

          if ciphertext_data.failure?
            flash[:error] = Form.message_values(ciphertext_data)
            routing.halt
          end
          enc_res = RequestDecrypt.new(App.config).call(
            current_account: @current_account,
            folder_name:,
            key_alias:,
            ciphertext_data: ciphertext_data.to_h
          )
          flash[:notice] = "Plaintext: #{enc_res['data']['attributes']['plaintext']}"
        rescue StandardError => e
          puts "FAILURE Creating key: #{e.inspect}"
          puts e.backtrace
          flash[:error] = 'Could not process ciphertext'
        ensure
          routing.redirect "/folders/#{folder_name}"
        end
      end
    end
  end
end

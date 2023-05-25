# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class App < Roda
    route('keys') do |routing|
      routing.on String do |folder_name|
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @keys_route = "/keys/#{folder_name}"
        # POST /keys/[folder_name]
        routing.post do
          key_data = Form::NewKey.new.call(routing.params)

          if key_data.failure?
            flash[:error] = Form.message_values(key_data)
            routing.halt
          end

          CreateNewKey.new(App.config).call(
            current_account: @current_account,
            folder_name:,
            key_data: key_data.to_h
          )
          flash[:notice] = 'Key created successfully'
        rescue StandardError => e
          puts "FAILURE Creating key: #{e.inspect}"
          puts e.backtrace
          flash[:error] = 'Could not create key'
        ensure
          routing.redirect "/folders/#{folder_name}"
        end
      end
    end
  end
end

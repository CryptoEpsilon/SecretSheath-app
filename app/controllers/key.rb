# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class App < Roda
    route('keys') do |routing|
      routing.on String do |folder_name|
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @keys_route = "/folders/#{folder_name}"

        routing.on String do |key_alias|
          routing.is 'accessors' do
            # POST /keys/[folder_name]/[key_alias]/accessors
            routing.post do
              req_body = JSON.parse(routing.body.read, symbolize_names: true)
              action = req_body[:action]
              accessor_info = Form::AccessorEmail.new.call(req_body)

              routing.halt 400, { error: 'Bad Request' }.to_json if accessor_info.failure?

              task_list = {
                'put' => { service: AddAccessor },
                'delete' => { service: RemoveAccessor }
              }

              task = task_list[action]
              task[:service].new(App.config).call(
                current_account: @current_account,
                accessor: accessor_info.to_h,
                folder_name:,
                key_alias:
              )
            rescue StandardError => e
              puts "FAILURE Adding accessor: #{e.inspect}"
              routing.halt 500, { message: 'Internal Server Error' }.to_json
            end
          end

          # GET /keys/[folder_name]/[key_alias]
          routing.get do
            GetKey.new(App.config).call(@current_account, folder_name, key_alias)
          rescue StandardError => e
            puts "FAILURE Getting key: #{e.inspect}"
            routing.halt 500, { message: 'Internal Server Error' }.to_json
          end

          # POST /keys/[folder_name]/[key_alias]
          routing.post do
            response = DeleteKey.new(App.config).call(@current_account, folder_name, key_alias)
            flash[:notice] = response['message']
          rescue StandardError => e
            puts "FAILURE Deleting key: #{e.inspect}"
            flash[:error] = 'Could not delete key'
          ensure
            routing.redirect @keys_route
          end
        end

        # POST /keys/[folder_name]
        routing.post do
          key_data = Form::NewKey.new.call(routing.params)

          if key_data.failure?
            flash[:error] = Form.message_values(key_data)
            routing.halt
          end
          key_data.to_h[:name].gsub!(/\s/, '_')

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

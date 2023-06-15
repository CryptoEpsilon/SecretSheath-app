# frozen_string_literal: true

require 'roda'

module SecretSheath
  # Web controller for SecretSheath API
  class App < Roda
    route('folders') do |routing|
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @folders_route = '/folders'

        routing.on String do |folder_name|
          # GET /folders/[folder_name]
          routing.get do
            folder_info = GetFolder.new(App.config).call(@current_account, folder_name)
            folder = Folder.new(folder_info)
            view :folder, locals: { current_account: @current_account, folder: }
          end

          # POST /folders/[folder_name]
          routing.post do
            response = DeleteFolder.new(App.config).call(@current_account, folder_name)
            flash[:notice] = response['message']
          rescue StandardError => e
            puts "FAILURE Deleting folder: #{e.inspect}"
            flash[:error] = 'Could not delete folder'
          ensure
            routing.redirect @folders_route
          end
        end

        # GET /folders/
        routing.get do
          if @current_account.logged_in?
            folder_list = GetAllFolders.new(App.config).call(@current_account)
            folders = Folders.new(folder_list)
            view :folders_all,
                 locals: { current_user: @current_account, folders: }
          else
            routing.redirect '/auth/login'
          end
        end

        # POST /folders/
        routing.post do
          folder_data = Form::NewFolder.new.call(routing.params)

          if folder_data.failure?
            flash[:error] = Form.message_values(folder_data)
            routing.halt
          end
          folder_data.to_h[:name].gsub!(/\s/, '_')

          CreateNewFolder.new(App.config).call(
            current_account: @current_account,
            folder_data: folder_data.to_h
          )
          flash[:notice] = 'Folder created successfully'
        rescue StandardError => e
          puts "FAILURE Creating folder: #{e.inspect}"
          flash[:error] = 'Could not create folder'
        ensure
          routing.redirect @folders_route
        end
      end
    end
  end
end

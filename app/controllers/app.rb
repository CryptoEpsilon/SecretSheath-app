# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require 'rack/session'

module SecretSheath
  # Base class for SecretSheath Web Application
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :assets, path: 'app/presentation/assets', group_subdirs: false,
                    js: { encrypt: 'encrypt_service.js',
                          decrypt: 'decrypt_service.js',
                          folder: 'folder.js',
                          key_manage: 'key_manage.js' }
    plugin :public, root: 'app/presentation/public'
    plugin :all_verbs
    plugin :multi_route
    plugin :flash
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'text/html; charset=utf-8'
      @current_account = CurrentSession.new(session).current_account
      routing.public
      routing.assets
      routing.multi_route

      # GET /
      routing.root do
        view :home, locals: { current_account: @current_account }
      end
    end
  end
end

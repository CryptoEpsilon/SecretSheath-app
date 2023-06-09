# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class App < Roda
    def gh_oauth_url(config)
      url = config.GH_OAUTH_URL
      client_id = config.GH_CLIENT_ID
      scope = config.GH_SCOPE

      "#{url}?client_id=#{client_id}&scope=#{scope}"
    end

    route('auth') do |routing|
      @oauth_callback = 'auth/sso_callback'
      @login_route = '/auth/login'
      routing.on 'login' do
        routing.is do
          # GET /auth/login
          routing.get do
            view :login, locals: { gh_oauth_url: gh_oauth_url(App.config),
                                   current_account: nil }
          end

          # POST /auth/login
          routing.post do
            credentials = Form::LoginCredentials.new.call(routing.params)

            if credentials.failure?
              flash[:error] = 'Please enter username and password'
              routing.redirect @login_route
            end

            authenticated = AuthenticateAccount.new(App.config)
                                               .call(username: credentials[:username], password: credentials[:password])
            current_account = Account.new(
              authenticated[:account],
              authenticated[:auth_token]
            )
            CurrentSession.new(session).current_account = current_account

            flash[:notice] = "Welcome back #{current_account.username}!"
            routing.redirect '/'
          rescue AuthenticateAccount::UnauthorizedError
            flash.now[:error] = 'Username and password did not match our records'
            response.status = 401
            view :login
          rescue AuthenticateAccount::ApiServerError => e
            App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Our servers are not responding -- please try later'
            response.status = 500
            routing.redirect @login_route
          end
        end

        # GET /auth/login/[registration_token]
        routing.get String do |registration_token|
          req_auth = SecureMessage.decrypt(registration_token)
          current_account = Account.new(req_auth)
          view :login, locals: { gh_oauth_url: gh_oauth_url(App.config),
                                 current_account: }
        end
      end

      # GET /auth/sso_callback
      routing.is 'sso_callback' do
        routing.get do
          authorized = AuthorizeGithubAccount.new(App.config)
                                             .call(routing.params['code'])

          if authorized[:set_password]
            routing.redirect "/auth/register/#{authorized[:registration_token]}"
            routing.halt
          end
          routing.redirect "/auth/login/#{authorized[:registration_token]}"
        rescue AuthorizeGithubAccount::UnauthorizedError
          flash[:error] = 'Could not login with Github'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "SSO LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Unexpected API Error'
          response.status = 500
          routing.redirect @login_route
        end
      end

      @logout_route = '/auth/logout'
      routing.on 'logout' do
        routing.get do
          CurrentSession.new(session).delete
          flash[:notice] = "You've been logged out"
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.on 'register' do
        routing.is do
          # GET /auth/register
          routing.get do
            view :register
          end

          # POST /auth/register
          routing.post do
            registration = Form::Registration.new.call(routing.params)
            if registration.failure?
              flash[:error] = Form.validation_errors(registration)
              routing.redirect @register_route
            end

            VerifyRegistration.new(App.config).call(registration)

            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect '/'
          rescue VerifyRegistration::ApiServerError => e
            App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Our servers are not responding -- please try later'
            routing.redirect @register_route
          rescue StandardError => e
            App.logger.error "Could not process registration: #{e.inspect}"
            flash[:error] = 'Registration process failed -- please try later'
            routing.redirect @register_route
          end
        end

        # GET /auth/register/<token>
        routing.get(String) do |registration_token|
          new_account = SecureMessage.decrypt(registration_token)
          flash.now[:notice] = 'Email Verified! Please choose a new password' unless new_account['set_password']
          view :register_confirm,
               locals: { new_account:,
                         registration_token: }
        end
      end
    end
  end
end

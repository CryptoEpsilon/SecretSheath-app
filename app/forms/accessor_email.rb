# frozen_string_literal: true

require_relative 'form_base'

module SecretSheath
  module Form
    # Form validation for adding an accessor to a key
    class AccessorEmail < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/account_details.yml')

      params do
        required(:email).filled(format?: EMAIL_REGEX)
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'form_base'

module SecretSheath
  module Form
    # Form validation for new key
    class EncryptForm < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/encrypt_form.yml')

      params do
        required(:plaintext).filled(:str?)
      end
    end
  end
end

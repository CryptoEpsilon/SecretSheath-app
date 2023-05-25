# frozen_string_literal: true

require_relative 'form_base'

module SecretSheath
  module Form
    # Form validation for new key
    class DecryptForm < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/decrypt_form.yml')

      params do
        required(:ciphertext).filled(:str?)
      end
    end
  end
end

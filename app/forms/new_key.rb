# frozen_string_literal: true

require_relative 'form_base'

module SecretSheath
  module Form
    # Form validation for new key
    class NewKey < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_key.yml')

      params do
        required(:name).filled
        optional(:description).maybe(:str?)
        optional(:keycontents).maybe(:str?)
      end
    end
  end
end

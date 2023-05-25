# frozen_string_literal: true

require_relative 'form_base'

module SecretSheath
  module Form
    # Form validation for new folder
    class NewFolder < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_folder.yml')

      params do
        required(:name).filled
        optional(:description).maybe(:str?)
      end
    end
  end
end

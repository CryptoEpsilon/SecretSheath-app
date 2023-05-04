# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class App < Roda
    route('keys') do |routing|
      view :keys
    end
  end
end

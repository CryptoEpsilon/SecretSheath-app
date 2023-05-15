# frozen_string_literal: true

module SecretSheath
  # Behaviors of the currently logged in account
  class Folder
    attr_reader :id, :name, :description

    def initialize(folder_info)
      @id = folder_info['attributes']['id']
      @name = folder_info['attributes']['name']
      @description = folder_info['attributes']['description']
    end
  end
end

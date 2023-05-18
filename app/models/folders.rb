# frozen_string_literal: true

require_relative 'folder'

module SecretSheath
  # Behaviors of the currently logged in account
  class Folders
    attr_reader :all

    def initialize(folders_list)
      @all = folders_list.map do |folder|
        Folder.new(folder['data'])
      end
    end
  end
end

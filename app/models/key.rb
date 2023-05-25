# frozen_string_literal: true

require_relative 'folder'

module SecretSheath
  # Behaviors of the currently logged in account
  class Key
    attr_reader :id, :name, :alias, :description, :short_alias, # basic info
                :folder # full details

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id             = attributes['id']
      @name           = attributes['name']
      @alias          = attributes['alias']
      @short_alias    = attributes['short_alias']
      @description    = attributes['description']
    end

    def process_included(included)
      @folder = Folder.new(included['folder'])
    end
  end
end

# frozen_string_literal: true

require_relative 'folder'

module SecretSheath
  # Behaviors of the currently logged in account
  class Key
    attr_reader :id, :name, :alias, :description, :short_alias, # basic info
                :folder, :children # full details

    def initialize(key_info)
      process_attributes(key_info['attributes'])
      process_include(key_info['include'])
      process_relationships(key_info['relationships'])
      process_policies(key_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id             = attributes['id']
      @name           = attributes['name']
      @alias          = attributes['alias']
      @short_alias    = attributes['short_alias']
      @description    = attributes['description']
    end

    def process_include(include)
      @folder = Folder.new(include['folder']) if include
    end

    def process_relationships(relationships)
      return unless relationships

      # @children = process_children(relationships['children'])
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'key',
          attributes: {
            id:,
            name:,
            alias:,
            short_alias:,
            description:
          },
          include: {
            folder:
          },
          relationships: {
            children:
          },
          policies:
        }, options
      )
    end
  end
end

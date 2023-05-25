# frozen_string_literal: true

module SecretSheath
  # Behaviors of the currently logged in account
  class Folder
    attr_reader :id, :name, :description,
                :owner, :sharers, :keys, :folders, :policies

    def initialize(folder_info)
      process_attributes(folder_info['attributes'])
      process_relationships(folder_info['relationships'])
      process_policies(folder_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @name = attributes['name']
      @description = attributes['description']
    end

    def process_relationships(relationships)
      return unless relationships

      @owner = Account.new(relationships['owner'])
      @sharers = process_sharers(relationships['sharers'])
      @keys = process_keys(relationships['keys'])
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end

    def process_keys(keys_info)
      return nil unless keys_info

      keys_info.map { |key| Key.new(key) }
    end

    def process_sharers(sharers)
      return nil unless sharers

      sharers.map { |sharer| Account.new(sharer) }
    end
  end
end

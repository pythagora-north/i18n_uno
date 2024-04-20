# frozen_string_literal: true

module I18nUno
  class Error < StandardError; end

  class Comparer
    attr_accessor :source_file, :target_file

    def initialize(source_file, target_file)
      @source_file = source_file
      @target_file = target_file
    end

    def compare
      source_keys = flatten_keys(normalize_data(source_file.content_hash))
      target_keys = flatten_keys(normalize_data(target_file.content_hash))

      new_keys     = compare_keys(target_keys, source_keys)
      removed_keys = compare_keys(source_keys, target_keys)

      I18nUno::Delta.new(
        new_keys: new_keys,
        removed_keys: removed_keys,
        target_keys_size: target_keys.size
      )
    end

    private

    def compare_keys(source_keys, target_keys)
      target_keys - source_keys
    end

    # Flattens the nested hash of translation keys into a flat array of dot-prefixed keys.
    # @param data [Hash] the translation file content
    # @param prefix [String] the current prefix to prepend to keys (used in recursion)
    # @return [Array] an array of flattened key strings
    def flatten_keys(data, prefix = '')
      data.each_with_object([]) do |(key, value), keys|
        full_key = "#{prefix}#{key}"
        if value.is_a?(Hash)
          keys.concat(flatten_keys(value, "#{full_key}."))
        else
          keys << full_key unless value.nil?
        end
      end
    end


    # Removes the first key for the data, since that is locale for that file content
    # @param data [Hash] the translation file content
    # @return [Hash] the translation file content without the locale key
    def normalize_data(data)
      if data.keys.first.length == 2 && data.keys.length == 1
        data[data.keys.first]
      else
        data
      end
    end
  end
end

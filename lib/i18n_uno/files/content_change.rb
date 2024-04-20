# frozen_string_literal: true

module I18nUno
  module Files
    module ContentChange
      # Reorders keys in the file to match the order of the source file.
      # @param sot_file [I18nUno::File] The source of truth file with the desired key order.
      def match_order_as_file!(sot_file)
        ordered_hash = {}
        ordered_hash[locale] = merge_preserving_key_order(
          sot_file.content_hash.values.first,
          content_hash.values.first
        )

        @content_hash = ordered_hash
      end

      # Adds missing keys to the target file and initializes them to nil.
      # @param delta [I18nUno::Delta] Contains the new keys to be added.
      def add_missing_keys_to_target_file!(delta)
        delta.new_keys.each do |key_path|
          keys = key_path.split('.').unshift(locale)
          deep_set_to_nil!(content_hash, keys)
        end
      end

      # Retrieves values from the file using dot-separated keys.
      # @param dot_keys [Array<String>] Array of keys to retrieve values for.
      # @return [Array] The values corresponding to the dot_keys.
      def values_from_keys(dot_keys)
        dot_keys.collect do |dot_keys|
          keys = dot_keys.split('.').unshift(locale)
          value = content_hash

          loop do
            value = value[keys.shift]
            break if keys.empty?
          end

          value
        end
      end

      # Updates the file with values from translated deltas.
      # @param delta [I18nUno::Delta] Contains the keys and their translated values.
      def set_values_from_delta!(delta)
        delta.new_keys.each_with_index do |key_path, index|
          keys = key_path.split('.').unshift(locale)
          value = content_hash

          loop do
            current_key = keys.shift

            if keys.empty?
              value[current_key] = delta.translated_values[index]
              break
            else
              value = value[current_key]
            end
          end
        end
      end

      # Removes specified keys from the file.
      # @param delta [I18nUno::Delta] Contains the keys to be removed.
      def remove_keys_from_file!(delta)
        delta.removed_keys.each do |key_path|
          keys = key_path.split('.').unshift(locale)
          deep_key_remove!(content_hash, keys)
        end
        save!
      end

      # Saves the file to HDD
      def save!
        ::File.open(file_path, 'w') do |file|
          yaml_content = content_hash.to_yaml(options: { line_width: -1 })
          yaml_content.sub!(/\A---\s*\n/, '')
          file.write(yaml_content)
        end
      end

      # Prepares a new file with all primitive values set to nil.
      # @param save_file [Boolean] Determines if the file should be saved immediately after setup.
      def setup_new_file(save_file)
        original_locale = @content_hash.keys.first
        @content_hash[locale] = @content_hash.delete(original_locale)
        set_primitives_to_nil!(@content_hash)
        save! if save_file
      end

      private

      # Recursively sets all primitive values in a hash to nil.
      # @param hash [Hash] The hash to modify.
      def set_primitives_to_nil!(hash)
        hash.each do |key, value|
          if value.is_a?(Hash)
            set_primitives_to_nil!(value)
          else
            hash[key] = nil
          end
        end
      end

      # Merges two hashes preserving the order of keys from the source hash.
      # @param source_hash [Hash] The source hash defining the order of keys.
      # @param target_hash [Hash] The target hash to merge.
      # @return [Hash] The merged hash with preserved key order.
      def merge_preserving_key_order(source_hash, target_hash)
        merged_hash = {}

        source_hash.each_key do |key|
          merged_hash[key] = if source_hash[key].is_a?(Hash) && target_hash[key].is_a?(Hash)
                               merge_preserving_key_order(source_hash[key], target_hash[key])
                             else
                               target_hash[key]
                             end
        end

        merged_hash
      end

      # Recursively removes a key from a nested hash.
      # @param obj [Hash] The hash from which to remove the key.
      # @param keys [Array<String>] The path of keys leading to the key to remove.
      def deep_key_remove!(obj, keys)
        first_key = keys.shift

        if keys.empty?
          obj.delete(first_key)
        else
          deep_key_remove!(obj[first_key], keys)
        end
      end

      # Sets all leaf nodes of a nested hash to nil.
      # @param obj [Hash] The hash to modify.
      # @param keys [Array<String>] The path of keys.
      def deep_set_to_nil!(obj, keys)
        last_key = keys.pop
        last_hash = keys.inject(obj) do |o, k|
          o[k] ||= {}
        end
        last_hash[last_key] = nil
      end
    end
  end
end

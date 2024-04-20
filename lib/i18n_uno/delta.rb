# frozen_string_literal: true

module I18nUno
  class Delta
    attr_accessor :new_keys, :removed_keys, :values, :translated_values, :target_file

    # @param new_keys [Array<String>] keys that are newly added.
    # @param removed_keys [Array<String>] keys that have been removed.
    # @param target_keys_size [Integer] the total number of keys in the target file.
    def initialize(new_keys: [], removed_keys: [], target_keys_size: 0)
      @new_keys = new_keys
      @removed_keys = removed_keys
      @values = []
      @translated_values = []
      @complete_file_diff = calculate_complete_file_diff(new_keys, target_keys_size)
    end

    # Calculates if the delta represents a complete difference of a file.
    # @return [Boolean] true if the new keys are equal to the total number of keys in the target.
    def calculate_complete_file_diff(new_keys, target_keys_size)
      new_keys.any? && new_keys.size == target_keys_size
    end

    # Determines if the entire file has been changed based on the delta.
    # @return [Boolean] true if all keys in the file are considered new.
    def complete_file_diff?
      @complete_file_diff
    end

    # Checks if there are any changes (new or removed keys).
    # @return [Boolean] true if there are any new or removed keys.
    def any_changes?
      any_new_keys? || any_removed_keys?
    end

    # Checks if there are any new keys in the delta.
    # @return [Boolean] true if there are new keys present.
    def any_new_keys?
      new_keys.any?
    end

    # Checks if there are any removed keys in the delta.
    # @return [Boolean] true if there are keys that have been removed.
    def any_removed_keys?
      removed_keys.any?
    end

    # Determines if there are any values ready to be translated.
    # This checks for the presence of non-nil entries in the values list.
    # @return [Boolean] true if there are non-nil values to translate.
    def anything_to_translate?
      values.compact.any?
    end

    # Populates the values list from a specified file based on the new keys.
    # This is intended to gather the actual values to be translated.
    # @param file [Object] typically an instance of a File class, used to extract values.
    def values_from!(file)
      @values = file.values_from_keys(new_keys)
    end
  end
end

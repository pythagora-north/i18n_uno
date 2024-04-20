# frozen_string_literal: true

module I18nUno
  class Configuration
    attr_accessor :load_path, :open_ai_model, :open_ai_key, :default_locale, :available_locales

    def initialize
      raise ConfigurationError, 'Rails must be present to use I18nUno' unless defined?(Rails)

      @load_path = ::File.join(Rails.root, 'config', 'locales')
      @open_ai_model = 'gpt-4-0613'
      @open_ai_key = nil
      @default_locale = nil
      @available_locales = nil
    end

    def validate!
      raise ConfigurationError, 'open_ai_key must be set for API operations' unless open_ai_key
      raise ConfigurationError, 'available_locales must be set' unless available_locales
      raise ConfigurationError, 'default_locale must be included in available_locales' if available_locales && !available_locales.include?(default_locale)
    end
  end

  class ConfigurationError < StandardError; end
end

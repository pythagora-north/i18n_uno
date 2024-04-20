# frozen_string_literal: true

require 'i18n_uno/version'
require 'i18n_uno/configuration'
require 'i18n_uno/railtie' if defined?(Rails)
require 'i18n_uno/arbiter'
require 'i18n_uno/comparer'
require 'i18n_uno/translator'
require 'i18n_uno/tree'
require 'i18n_uno/file'
require 'i18n_uno/delta'

module I18nUno
  class << self
    attr_accessor :config
  end

  def self.config
    @config ||= I18nUno::Configuration.new
  end

  def self.configure
    yield(config)
  end
end

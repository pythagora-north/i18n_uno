# frozen_string_literal: true

require 'fileutils'
require 'i18n_uno/files/content_change'

module I18nUno
  class File
    include I18nUno::Files::ContentChange

    attr_accessor :content_hash
    attr_reader   :file_path, :locale

    def initialize(file_path)
      @file_path = file_path

      @locale = ::File.basename(file_path, '.yml')
      @content_hash = YAML.load_file(file_path)
    end

    def pp_file_name
      file_path.gsub(%r{#{I18nUno.config.load_path}/?}, '')
    end

    def file_identifier
      file_path.gsub(%r{/#{locale}\.yml$}, '')
    end

    def create_in_locale(locale, save_file = false)
      new_path = path_in_locale(locale)
      FileUtils.cp(file_path, path_in_locale(locale))

      file = I18nUno::File.new(new_path)
      file.setup_new_file(save_file)
      file
    end

    def path_in_locale(locale)
      new_path = file_path.gsub(%r{/#{self.locale}\.yml$}, "/#{locale}.yml")
    end
  end
end

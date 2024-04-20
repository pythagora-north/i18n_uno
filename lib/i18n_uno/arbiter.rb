# frozen_string_literal: true

module I18nUno
  class Arbiter
    attr_reader :translators, :trees, :source_of_truth_tree, :target_locales

    def initialize
      @translators = []
      @trees  = {}

      setup_configurations
    end

    def translate
      print_translations_info

      target_locales.each do |target_locale|
        collect_locale_changes(target_locale)
        process_changes(target_locale)
      end
    end

    private

    def setup_configurations
      check_locale_availability
      setup_signal_handling
      setup_target_locales
      setup_translation_trees
    end

    def check_locale_availability
      if I18nUno.config.available_locales.nil?
        raise I18nUno::ConfigurationError, 'No available locales specified. Please set the available locales in the configuration file.'
      end
    end

    def setup_target_locales
      @target_locales = I18nUno.config.available_locales - [I18nUno.config.default_locale]
    end

    def setup_translation_trees
      @target_locales.each { |locale| @trees[locale] = I18nUno::Tree.new(locale) }
      @source_of_truth_tree = I18nUno::Tree.new(I18nUno.config.default_locale)
    end

    def collect_locale_changes(target_locale)
      puts "\nChecking for translation changes for locale '#{target_locale}'\n"

      source_of_truth_tree.each do |sot_file|
        target_file = @trees[target_locale].find_or_create_file(sot_file)

        comparer = I18nUno::Comparer.new(sot_file, target_file)
        diff_delta = comparer.compare
        @trees[target_locale].add_delta!(target_file, diff_delta)
      end
    end

    def process_changes(target_locale)
      @trees[target_locale].process_delta_changes(source_of_truth_tree)
    end

    def setup_signal_handling
      Signal.trap('SIGINT') do
        puts "\nExiting I18n Uno ..."
        target_locales.each do |target_locale|
          @trees[target_locale].clean_not_processed_files
        end
        exit
      end
    end

    def print_translations_info
      if source_of_truth_tree.empty?
        puts "No translation files found in the specified path (#{I18nUno.config.load_path}}/**/#{I18nUno.config.default_locale}.yml). Please check the path and try again."
        exit(0)
      else
        puts "Listing translation files for the default locale '#{I18nUno.config.default_locale}':\n\n"
        source_of_truth_tree.files.each_slice(2) do |file_pair|
          file_pair.map! { |file| file.file_path.gsub(%r{#{I18nUno.config.load_path}/?}, '') }
          print_string = file_pair.size.even? ? "- %-40s - %-40s\n" : "- %-40s\n"
          printf(print_string, *file_pair)
        end
      end
    end
  end
end

# frozen_string_literal: true

namespace :i18n_uno do
  desc 'Translate all your I18n files'
  task translate: :environment do
    begin
      I18nUno.config.validate!

      i18n_uno = I18nUno::Arbiter.new
      i18n_uno.translate
    rescue I18nUno::ConfigurationError => e
      puts("#{e.class}: #{e.message}")
    end
  end
end

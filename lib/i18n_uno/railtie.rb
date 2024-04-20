# frozen_string_literal: true

module Geocoder
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'tasks/i18n_uno.rake'
      end
    end
  end
end

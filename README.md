# i18nUno

i18nUno is a gem that helps you translate your Rails application into any language you choose. It utilizes the OpenAI API for translations and supports all languages. It's easy to use, and by implementing Git hooks, you can set it up to automatically add new translations or delete old ones as a pre-commit hook.

## Installation

Add this line to your application's Gemfile:

```ruby
group :development do
  ...
  gem 'i18n_uno'
end
```

And then execute:

    $ bundle install

## Prerequisites

To use the gem, adhere to the standard procedures outlined in the [Rails I18n support guide](https://guides.rubyonrails.org/i18n.html). While you may organize your folders as you wish, all localization files must be named following the `$locale.yml` format, such as `en.yml` for English. The i18n Uno gem will leverage these files to generate new ones for additional languages you wish to include, for instance, `es.yml` for Spanish, `de.yml` for German etc.

## Configuration

To utilize the gem, create a file `config/initializers/i18n_uno.rb` and configure the gem with your OpenAI credentials. Additional settings are available for customization.

```ruby
I18nUno.configure do |config|
  config.open_ai_key = ENV['OPEN_AI_API_KEY']         # Required: Found at https://platform.openai.com/account/api-keys
  config.default_locale                               # Required: You can set it to I18n.config.default_locale
  config.available_locales                            # Required: I18n.config.default_locale and locales you want to translate to
  config.open_ai_model                                # Optional: Defaults to 'gpt-4-0613'
  config.load_path                                    # Optional: Defaults to 'config/locales'
end
```

Although changing the model is supported, it is strongly recommended to stick with gpt-4 models due to the significant quality difference compared to gpt-3 models.

## Usage

Before running the gem, ensure you've added the desired languages to `config.available_locales` or in the `config/application.rb` file.

```ruby
config.i18n.available_locales = [:en, :bs, :de]
```

With these settings, translations will be executed to add all necessary files to support these languages. From this point, simply run:

```bash
rake i18n_uno:translate
```

from your application folder. i18n Uno will then add new translation files, and you'll be ready to go. If new keys are added during development, running the above command again will automatically add and translate these new keys. Key removal is also supported and will be propagated to all language files.

## Continuous Management of Internationalization

Your default locale serves as the foundational reference for your application's internationalization. Whenever modifications are made to the localization files, executing the previously mentioned gem command will automatically update translations across all other supported languages, adding or removing them as necessary.

To ensure seamless integration of this process, it's advisable to configure a pre-commit hook that triggers the above command. This step helps maintain consistency by preventing the introduction of new keys without their corresponding translations.

It's important to note that the gem is designed to respect the integrity of your source of truth files (the default locale) and, as such, will not alter these files directly. Additionally, it does not track changes to existing keys, focusing instead on the addition or removal of translations based on the current state of your default locale files.

## Setting up application for internationalization

If you are not already supporting internationalization in your rails application you can do that simply by adding `locale` field to your `user` model.

```ruby
  class AddLocaleToUsers < ActiveRecord::Migration
    def change
      add_column :users, :locale, :string, default: 'en'
    end
  end
```

From there adding you simply need to add before action to `app/controllers/authenticated_controller.rb`. This would very based on your application but this would be the standard way.

```ruby
  before_action :set_locale!

  def set_locale!
    I18n.locale = current_user.locale
  end
```

That would be it, magic of rails will take care of the rest.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/i18n_uno.
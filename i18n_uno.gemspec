# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i18n_uno/version'

Gem::Specification.new do |spec|
  spec.name          = 'i18n_uno'
  spec.version       = I18nUno::VERSION
  spec.authors       = ['Haris Krajina', 'hkraji']
  spec.email         = ['haris@pythagoranorth.com']

  spec.summary       = 'i18n Uno levrages power of ChatGPT API to translate your i18n files.'
  spec.description   = 'i18n Uno is simple CLI tool that will completly translate your application to any desired language.'
  spec.homepage      = 'https://github.com/pythagora-north/i18n_uno'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/pythagora-north/i18n_uno'
  spec.metadata['changelog_uri'] = 'https://github.com/pythagora-north/i18n_uno/blob/main/Changes.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end

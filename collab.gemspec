# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'collab/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name          = 'collab'
  spec.version       = Collab::VERSION
  spec.authors       = ['Ben Aubin']
  spec.email         = ['ben@benaubin.com']

  spec.summary       = 'Collaborative editing on Rails.'
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://github.com/benaubin/rails-collab'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/benaubin/rails-collab'
  spec.metadata['changelog_uri'] = 'https://github.com/benaubin/rails-collab/blob/master/CHANGELOG.md'

  spec.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']

  spec.add_dependency 'rails', '~> 6.1.5'
  spec.add_dependency 'faraday', '~> 1.8.0'
  spec.add_dependency 'faraday_middleware', '~> 1.2.0'
  spec.add_dependency 'faraday-encoding', '~> 0.0.5'

  # allow for adapter of choice
  # spec.add_dependency 'faraday-httpclient', '~> 1.0.1'
  # spec.add_dependency 'faraday-net_http', '~> 1.0.1'
  # spec.add_dependency 'faraday-net_http_persistent', '~> 1.2.0'
  # spec.add_dependency 'net-http-persistent', '~> 4.0.1'
  # spec.add_dependency 'faraday-em_http', '~> 1.0.0'

  spec.add_development_dependency 'puma'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'webpacker'
end

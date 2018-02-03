# ./Gemfile

source "https://rubygems.org"

# ruby "2.5.0"
platform :jruby do
  gem 'jruby-jars', '9.1.15.0'
  gem 'jruby-rack'
end

gem 'bundler', '~> 1.16'
gem 'logging'

# Web framework: Core
gem "puma"
gem "roda"

# Web framework: Html
gem "tilt"
gem "erubis"
# gem 'forme'
gem 'roda-tags'
gem "r18n-core"
gem "roda-i18n"

# Javascript Runtime Support
gem 'execjs'
gem "therubyracer", platform: :ruby
gem 'therubyrhino', platform: :jruby
gem 'uglifier'

gem 'sass'
# gem 'bootstrap-sass'
# gem 'semantic-ui-sass'
# gem 'sprockets-sass'
# gem 'roda-sprocket_assets'

# Todo: Can't figure out how to use these yet!
gem 'tilt-pipeline'
# gem 'tilt-indirect'
#

# Core Components
gem 'dry-types'
gem 'dry-monads'
# gem 'dry-struct'
# gem 'dry-container'
# gem 'dry-auto_inject'


# General Utilities
gem 'skn_utils'
gem 'concurrent-ruby', require: 'concurrent'
gem 'time_math2', require: 'time_math'
gem 'mime-types'
gem 'rake'

# Persistence
gem 'pg', platform: :ruby
gem 'rom'
gem 'rom-sql'

# Web Security
gem 'rack-contrib'
gem "rack-protection"
gem "rack_csrf"
gem "bcrypt"
gem 'warden'

group :development do
  gem 'pry'
  gem "racksh", require: false

  gem 'warbler', '>= 2.0', require: false
  gem 'yard'
  gem 'rdoc'
end

group :test do
  gem 'rspec'
  gem 'faker'
  gem 'rack-test'
  # gem 'rspec-roda'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'rack_session_access'
  gem 'simplecov', :require => false
  gem "rom-factory"
  gem 'poltergeist'
end

# ./Gemfile

source "https://rubygems.org"

gem 'logging'

# Web framework: Core
gem "puma"
gem "roda"

# Web framework: Html
gem "tilt"
gem "erubis"
gem 'forme'
gem 'roda-tags'
gem "r18n-core"
gem "roda-i18n"

# Javascript Runtime Support
gem 'execjs'
gem "therubyracer", platform: [:mri, :ruby]
# gem 'therubyrhino', platform: :jruby
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
gem 'pg'
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
  gem "racksh"
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

# ./Gemfile

source "https://rubygems.org"

ruby "2.4.2"

gem 'logging'

# Web framework: Core
gem "puma"
gem "roda", "~> 3.3.0"

# Web framework: Html
gem "tilt"
gem "erubis"

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
# gem 'tilt-pipeline'
# gem 'tilt-indirect'

# Core Components
gem 'dry-types'
gem 'dry-struct'
gem 'dry-monads'

# General Utilities
gem 'skn_utils'
gem 'time_math2', require: 'time_math'
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
  gem 'pry-byebug'
  gem "racksh"
  gem 'rubocop', require: false
end

group :test do
  gem 'rspec'
  gem 'simplecov'
  gem "rom-factory"
end

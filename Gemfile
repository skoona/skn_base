# ./Gemfile

source "https://rubygems.org"

ruby "2.4.1"

# Web framework: Core
gem "puma"
gem "roda"

# Web framework: Html
gem "tilt"
gem "erubis"
gem "builder"

# Javascript Runtime Support
# gem 'execjs'
# gem "therubyracer", platform: [:mri, :ruby]
# gem 'therubyrhino', platform: :jruby


# General Utilities
gem 'skn_utils'
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

group :development do
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'pry-byebug'
  gem "racksh"
  gem 'rubocop'
end

group :test do
  gem 'rspec'
  gem 'simplecov'
  gem "rom-factory"
end

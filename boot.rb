# File: ./boot.rb

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)

require 'bundler/setup' # Setup LoadPath for gems listed in the Gemfile.

Bundler.require(:default, ENV['RACK_ENV'].to_sym) # Require all the gems for this environment

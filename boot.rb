# File: ./boot.rb

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)

%w[strategy routes models].each do |path_name|
  codes = File.expand_path(path_name, __dir__)
  $LOAD_PATH.unshift(codes) unless $LOAD_PATH.include?(codes)
end

begin
  require 'bundler/setup' # Setup LoadPath for gems listed in the Gemfile.

  require "utils/string_inquirer"

  Bundler.require(:default, ENV['RACK_ENV'].to_sym) # Require all the gems for this environment

rescue Bundler::BundlerError => ex
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

SknSettings.load_config_basename! ENV['RACK_ENV'] || 'development'

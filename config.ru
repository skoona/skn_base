# ##
# File: ./config.ru
#
# encoding: UTF-8
# rack.version: bundler

$:.unshift(Dir.pwd)

# require 'puma'

require_relative "main/skn_base"

app = case ENV['RACK_ENV']
        when 'development', 'test'
          require "pry"
          Skn::SknBase.app
        else
          Skn::SknBase.freeze.app
      end

run app

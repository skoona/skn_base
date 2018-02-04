# ##
# File: ./config.ru
#
# encoding: UTF-8

$:.unshift(Dir.pwd)

require_relative "main/skn_base"

app = case ENV['RACK_ENV']
        when 'development', 'test'
          require "pry" unless defined?($servlet_context)
          Skn::SknBase.app
        else
          Skn::SknBase.freeze.app
      end

run app

#!/usr/bin/env ruby
#
# File: ./config.ru

require_relative "skn_base"

app = case ENV['RACK_ENV']
        when 'development', 'test'
          SknBase.app
        else
          SknBase.freeze.app
      end

run app

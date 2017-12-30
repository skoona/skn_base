#!/usr/bin/env ruby
#
# File: ./config.ru

require 'puma'
require_relative "main/skn_base"

app = case ENV['RACK_ENV']
        when 'development', 'test'
          Skn::SknBase.app
        else
          Skn::SknBase.freeze.app
      end

run(app)

#!/usr/bin/env ruby
# ./config.ru

require 'bundler/setup'
require_relative "skn_base"

begin
  require "pry-byebug"
rescue LoadError
end

run SknBase.freeze.app

#!/usr/bin/env rake

# require_relative 'main/skn_base'
#
# require 'rspec/core'
# require 'rspec/core/rake_task'
#
# task default: :spec
#
# desc 'Run all specs in spec directory'
# RSpec::Core::RakeTask.new(:spec)

require 'warbler'
Warbler::Task.new

namespace :assets do
  desc "Precompile the assets"
  task :precompile do
    require './main/skn_base'
    Skn::SknBase.compile_assets
  end
end

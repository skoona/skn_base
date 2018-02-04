# File: ./main/boot.rb

# ##
# Setup Basic Configuration and Gem Loadpath
#
begin
  require 'java'
  require 'bundler'
  require 'bundler/setup' # Setup LoadPath for gems listed in the Gemfile.

  require_relative '../config/version'              # Skn::Version
  require "securerandom"                            # Augments User Security

  # Bundler.require #(:default, ENV['RACK_ENV'].to_sym) # Require all the gems for this environment

  Dir['./lib/java/postgresql*.jar'].each do |jarfile|
    require File.expand_path(jarfile, File.dirname(".."))
  end

  require "concurrent"
  require "skn_utils"
  require "time_math"

  # Load application settings & JNDI Support
  require_relative 'mounted_paths'
  runtime_config = MountedPaths.get_protected_resource('Packaging.configName')
  ENV['RACK_ENV'] = runtime_config
  SknSettings.load_config_basename!(runtime_config)

  flist =  Dir['./tmp/content/*'] # remove prior downloads
  unless flist.empty?
    fcount = File.delete(*flist)
    puts "TMP Folder Cleaner: Unlinked # #{fcount} files."
  end

rescue Bundler::BundlerError, StandardError => ex
  $stderr.puts ex.message
  if ex.is_a?(Bundler::BundlerError)
    $stderr.puts "Run `bundle install` to install missing gems"
    exit ex.status_code
  else
    $stderr.puts ex.backtrace[0..8]
    exit 1
  end
end

# ##
# Setup Logger
#
require "logging"
begin
  Logging.init(:debug, :info, :perf, :warn, :success, :error, :fatal)
  dpattern = Logging.layouts.pattern({ pattern: '%d %c:%-5l %m\n',
                                       date_pattern: '%Y-%m-%d %H:%M:%S.%3N' })
   astdout = Logging.appenders.stdout( $stdout, :layout => dpattern)
  arolling = Logging.appenders.rolling_file( 'rolling_log',
                                             :filename => "./log/#{SknSettings.env}.log",
                                             :age => 'daily',
                                             :size => 12582912,
                                             :keep => 9,
                                             :layout => dpattern,
                                             :color_scheme => 'default' )
  Logging.logger.root.level = (SknSettings.env.production? ? :debug : :debug )
  Logging.logger.root.appenders = (SknSettings.env.test? ? arolling : [astdout, arolling] )

  SknSettings.logger = Logging.logger['SKN']

  SknSettings.logger.info "SknSettings Logger Setup Complete! loaded: #{SknSettings.env} DB-URL: #{SknSettings.postgresql.url}"
rescue StandardError => e
  SknSettings.logger = Logger.new($stdout)
  SknSettings.logger.error "SknSettings Logger Setup Failed: loaded: #{SknSettings.env}, EMsg: #{e.message}"
end


begin
  # if defined?($servlet_context)
  #   require "jruby-rack"
  # else
  #   require "rack"
  # end
  require 'rack/contrib'
  require 'rack/protection'
  require "warden"
  require 'erb'
  require 'tilt/pipeline'
  require "roda"
  require "r18n-core"
  require "sass"

  require_relative '../persistence/persistence'
  require_relative '../strategy/strategy'
  require_relative 'init_warden'


rescue StandardError => ex
  $stderr.puts ex.message
  $stderr.puts ex.backtrace[0..8]
  exit 1
end

# File: ./boot.rb

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)

%w[strategy routes].each do |path_name|
  codes = File.expand_path(path_name, __dir__)
  $LOAD_PATH.unshift(codes) unless $LOAD_PATH.include?(codes)
end

begin
  require 'bundler/setup' # Setup LoadPath for gems listed in the Gemfile.
  require_relative 'config/version'                 # Skn::Version
  require "securerandom"                            # Augments User Security

  Bundler.require(:default, ENV['RACK_ENV'].to_sym) # Require all the gems for this environment
  SknSettings.load_config_basename!(ENV['RACK_ENV'] || 'development')

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
  Logging.logger.root.level = (SknSettings.env.production? ? :info : :debug )
  Logging.logger.root.appenders = (SknSettings.env.test? ? arolling : [astdout, arolling] )

  SknSettings.logger = Logging.logger['SKN']

  # app.env[RACK_LOGGER] = SknSettings.logger

  SknSettings.logger.info "SknSettings Logger Setup Complete! loaded: #{SknSettings.env}"
rescue StandardError => e
  SknSettings.logger = Logger.new($stdout)
  SknSettings.logger.error "SknSettings Logger Setup Failed: loaded: #{SknSettings.env}, EMsg: #{e.message}"
end


begin
  require_relative 'config/rom'

rescue StandardError => ex
  $stderr.puts ex.message
  $stderr.puts ex.backtrace[0..8]
  exit 1
end

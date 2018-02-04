# encoding: UTF-8
# Disable Rake-environment-task framework detection by uncommenting/setting to false
Warbler.framework_detection = false

# Warbler web application assembly configuration file
Warbler::Config.new do |config|
  config.features             = %w(runnable)
  config.bundler              = true
  config.dirs                 = %w(assets bin config i18n lib main persistence routes strategy views log tmp META-INF)
  config.bundle_without       = ['development', 'test']
  config.override_gem_home    = true
  config.pathmaps.application = ["WEB-INF/%p"]
  config.includes             = FileList["config.ru", "Gemfile", "Gemfile.lock"]
  config.java_libs           += FileList["lib/java/*.jar"]
  config.autodeploy_dir       = "target/"
  config.jar_name             = "sknbase"
  config.gem_path             = "/WEB-INF/vendor/bundle"
  config.gem_excludes         = [/^(spec)\//]
  config.webxml.booter        = :rack
  config.webxml.rack.env      = 'production'
  config.webxml.rackup.path   = 'WEB-INF/config.ru'
  config.public_html         += FileList["META-INF/context.xml","public/**/*"]
  config.webxml.jndi          = 'jdbc/iseriesDataSourceRef'
  config.webxml.jruby.min.runtimes  = 1
  config.webxml.jruby.max.runtimes  = 1
  config.webxml.jruby.compat.version = "2.0"
end

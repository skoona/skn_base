##
# <root>/main/mounted_paths.rb
#
# Composes a file system path for accessing remote files
# - Uses config/settings.yml and settings/<environment>.yml
#
# Usage:
# value = MountedPaths.windExclusionFormsPath
#  or
# value = MountedPaths.get_shared_resource(:windExclusionFormsPath,'someFileName.ext', 'windHail/' )
#  or
# value = MountedPaths.get_protected_resource("platform.windExclusionFormsPath")  # note additiona of platform prefix -- requires whole key
#

class << (MountedPaths = Object.new)

  import javax.naming.InitialContext
  import javax.naming.NameNotFoundException

  APP_KEY = "skn"

  #def initialize
  #  # not needed as this is a static class
  #  raise NotImplementedError, "Do Not Instantiate this class"
  #end

  def applicationAttachmentRootPath(target_file_name=nil, optional_dir=nil)
    compose_mount_point(:applicationAttachmentRootPath, optional_dir, target_file_name)
  end


  ##
  # upto Three part value
  # returns "#{keyValue}#{optional_dir}#{target_file_name}"
  #         "#{keyValue}#{actionNameStructure}#{paramsList}"
  def get_shared_resource(key, target_file_name=nil, optional_dir=nil)
    compose_mount_point(key, optional_dir, target_file_name)
  end
  ##
  # Single part value
  # returns keyValue
  def get_protected_resource(key)
    get_platform(key)
  end

  private

  def compose_mount_point(key, opts, target)
    mount = get_platform(key)
    path  = get_path(key, opts, target)
    "#{mount}#{path}#{opts}#{target}"
  end

  def get_path(key, opts, target)
    path  = SknSettings.mountedPaths.path[key]
  end

  def get_platform(key)
    value = nil
    real_key = key
    real_key = key.to_sym unless key.kind_of? Symbol

    value = read_any_jndi_resource("#{APP_KEY}.#{real_key.to_s}")
    value = read_any_jndi_resource(real_key) unless value.present?

    unless value.present?
      value = SknSettings.mountedPaths.platform[real_key]
      value = eval("Settings.#{real_key.to_s}") rescue nil  unless value.present?
      debug_output "MountedPaths.#{__method__}() local configuration returns value=#{(real_key.to_s.include?("word") ? "[secured]" :  value.to_s)} for key=#{real_key.to_s}"
    end

    value
  end

  def read_any_jndi_resource(key)
    value = nil
    if defined?($servlet_context)
      begin
        ctx = InitialContext.new
        context = ctx.lookup('java:comp/env')
        value = context.lookup(key.to_s)
        debug_output "MountedPaths.#{__method__}() JNDI returns #{(key.to_s.include?("word") ? "[secured]" : value.to_s ) } for #{key.to_s}"
      rescue NameNotFoundException => e
        value = nil
        debug_output "MountedPaths.#{__method__}() JNDI failed to return a value for key: #{key.to_s}, with this error=#{e.class.name.to_s}, #{e.message}"
      end
    end
    value
  end

  def debug_output(msg)
    SknSettings.logger? ? SknSettings.logger.debug(msg) : puts(msg)
  end

end

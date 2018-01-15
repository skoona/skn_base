# File: views/helpers/html_helpers.rb
#
module Skn
  class SknBase

    def registry_service
      Services::ServicesRegistry.new(roda_context: self)
    end

    def menu_active?(item_path)
      request.path.eql?(item_path) ? 'active' : ''
    end

    def wrap_html_response(service_response, redirect_path=root_path)
      @page_controls = service_response
      flash[:notice] = @page_controls.message unless @page_controls.message.nil?
      redirect redirect_path, notice: @page_controls.message and return unless @page_controls.success
    end

    def wrap_html_and_redirect_response(service_response, redirect_path=root_path)
      @page_controls = service_response
      flash[:notice] = @page_controls.message unless @page_controls.message.nil?
      redirect redirect_path, notice: @page_controls.message and return
    end

    def wrap_json_response(service_response)
      @page_controls = service_response
      render(json: @page_controls.to_hash, status: (@page_controls.package.success ? :accepted : :not_found), layout: false, content_type: :json) and return
    end

    def flash_message(rtype, text, now=false)
      type = [:success, :info, :warning, :danger].include?(rtype.to_sym) ? rtype.to_sym : :info
      if text.is_a?(Array)
        text.flatten.each do |val|
          now ? flash_message_now(type, val) : flash_message_next(type, val)
        end
      else
        now ? flash_message_now(type, text) : flash_message_next(type, text)
      end
    end

    def attempted_page_name
      attempted_page&.empty? ? '' : attempted_page.split('/').last
    end
    def attempted_page
      session['skn.attempted.page'] || ""
    end

    def current_page_name
      current_page&.empty? ? '' : current_page.split('/').last
    end
    def current_page
      request.path
    end

    def choose_content_icons(content)
      if content.content_type.include?('LicensedStates')
        '<i class="fa fa-balance-scale fa-2x"></i>'
      elsif content.content_type.include?('Notification')
        '<i class="fa fa-envelope-open-o fa-2x"></i>'
      elsif content.filename.include?('pdf')
        '<i class="fa fa-file-pdf-o fa-2x"></i>'
      elsif content.filename.include?('jpg') or content.filename.include?('png')
        '<i class="fa fa-file-image-o fa-2x"></i>'
      elsif content.filename.include?('log')
        '<i class="fa fa-file-text-o fa-2x"></i>'
      else
        '<i class="fa fa-file-o fa-2x"></i>'
      end
    end

    # Rails should have a 'number_to_human_size()' in some version ???
    def human_filesize(value)
      {
          'B'  => 1024,
          'KB' => 1024 * 1024,
          'MB' => 1024 * 1024 * 1024,
          'GB' => 1024 * 1024 * 1024 * 1024,
          'TB' => 1024 * 1024 * 1024 * 1024 * 1024
      }.each_pair { |e, s| return "#{(value.to_f / (s / 1024)).round(1)} #{e}" if value < s }
    end

    private

    def flash_message_next(type, text)
      if flash[type] and flash[type].is_a?(Array)
        flash[type].push( text )
      elsif flash[type] and flash[type].is_a?(String)
        flash[type] = [flash[type], text]
      else
        flash[type] = [text]
      end
    end

    def flash_message_now(type, text)
      if flash.now[type] and flash.now[type].is_a?(Array)
        flash.now[type].push( text )
      elsif flash.now[type] and flash.now[type].is_a?(String)
        flash.now[type] = [flash.now[type], text]
      else
        flash.now[type] = [text]
      end
    end


  end
end

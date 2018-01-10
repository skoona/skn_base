# File: views/helpers/html_helpers.rb
#
module Skn
  class SknBase

    def menu_active?(item_path)
      request.path.eql?(item_path) ? 'active' : ''
    end

    def flash_message(rtype, text, now=false)
      type = [:success, :info, :warning, :danger].include?(rtype.to_sym) ? rtype.to_sym : :info
      if flash[type] and flash[type].is_a?(Array)
        now ? flash.now[type].push( text ) : flash[type].push( text )
      elsif flash[type] and flash[type].is_a?(String)
        if now
          flash.now[type] = [flash[type], text]
        else
          flash[type] = [flash[type], text]
        end
      else
        if now
          flash.now[type] = [text]
        else
          flash[type] = [text]
        end
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


  end
end

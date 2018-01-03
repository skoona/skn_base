# File: views/helpers/html_helpers.rb
#
module Skn
  class SknBase

    def menu_active?(item_path)
      request.path.eql?(item_path) ? 'active' : ''
    end

    def flash_message(rtype, text)
      type = [:success, :info, :warning, :danger].include?(rtype.to_sym) ? rtype.to_sym : :info
      if flash[type] and flash[type].is_a?(Array)
        flash[type] << text
      elsif flash[type] and flash[type].is_a?(String)
        flash[type] = [flash[type], text]
      else
        flash[type] = [text]
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

  end
end

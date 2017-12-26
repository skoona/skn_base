# File: views/helpers/base_helpers.rb
#
module Skn
  class SknBase
    def menu_active?(item_path)
      request.path.eql?(item_path) ? 'active' : ''
    end
  end
end
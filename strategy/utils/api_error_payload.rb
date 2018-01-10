# <root>/app/beans/api_error_payload.rb
#
# message definition in <root>/config/locales/en.yml
#
#
# before_action :determine_if_api_request_is_authorized_or_call_render_api_error...
#
# def render_api_error_payload(identifier, status: :bad_request)
#   render json: APIErrorPayload.new(identifier, status), status: status
# end
#
# ##
#   # get apis/:agency_num/members
#   def members
#     @page_controls = systems_service.content_profile_apis(:members, params['id'])
#     render( json: @page_controls.payload, status: @page_controls.status)
#   end
#
#   rescue_from StandardError do |e|
#     render( json: APIErrorPayload.call(:unexpected_exception, :bad_request, e.message), status: :bad_request)
#   end
#
#   def unknown_api_request
#     render( json: APIErrorPayload.call(:routing_error, :forbidden, request.env['REQUEST_URI']), status: :forbidden)
#   end
# ##
# ref: https://medium.com/@stevenpetryk/providing-useful-error-responses-in-a-rails-api-24c004b31a2e#.m1ofyq22b
# ref: http://guides.rubyonrails.org/i18n.html#passing-variables-to-translations
# ##

module Utils
  class APIErrorPayload

    def self.call(*args)
      self.new.call(*args)
    end

    def initialize
      # nothing to do here: i.e. State Less
    end

    def call(identifier, status, additional_detail=nil)
      {
          status: Rack::Utils.status_code(status),
          code: identifier,
          additional_detail: additional_detail,
          title: translated_payload[:title],
          detail: translated_payload[:detail]
      }
    end

    def translated_payload
      I18n.translate("errors.#{identifier}")
    end

  end
end

require 'json'

require 'gdocs/concerns/requests'

module Gdocs
  module Models
    GOOGLE_SLIDES = "https://slides.googleapis.com/v1/presentations"

    class Presentation
      include Concerns::Requests

      def initialize(token)
        if token.to_s.empty?
          raise ArgumentError.new("Auth Token must be present")
        end

        @data = {}
        @token = token
      end

      # See https://developers.google.com/slides/api/reference/rest/v1/presentations/get
      def run_get(presentation_id)
        response_body = presentation_get_request("/#{presentation_id}")
        @data.merge! response_body
        self
      end

      def presentation_get_request(url_path)
        uri = URI(GOOGLE_SLIDES + url_path)

        res = get_request(uri, auth_token: @token)
        JSON(res.body)
      end
    end
  end
end

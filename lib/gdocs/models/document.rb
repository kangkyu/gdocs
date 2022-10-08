require 'net/http'
require 'json'

module Gdocs
  module Models
    class Document
      attr_writer :data

      def initialize(document_id)
        @document_id = document_id
        @data = {}
      end

      def title
        # to_s.camelize(:lower) if ActiveSupport
        field = __method__.to_s.split('_').inject([]){ |buffer, e| buffer + [buffer.empty? ? e : e.capitalize] }.join
        value = instance_variable_get("@#{__method__.to_s}") || instance_variable_set("@#{__method__.to_s}", @data[field])
        value
      end

      def run_request
        # See https://developers.google.com/docs/api/reference/rest/v1/documents/get
        uri_string = "https://docs.googleapis.com/v1/documents/#{@document_id}"
        url = URI uri_string

        req = Net::HTTP::Get.new(uri_string)
        req['Authorization'] = "Bearer #{ENV['GDOCS_AUTH_TOKEN']}"

        res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
          http.request(req)
        end
        @data.merge! JSON(res.body)
        self
      end
    end
  end
end

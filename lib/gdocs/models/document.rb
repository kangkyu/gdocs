require 'net/http'
require 'json'

module Gdocs
  module Models
    class Document
      attr_writer :data # for testing

      def initialize
        @data = {}
        @token = ENV['GDOCS_AUTH_TOKEN']
      end

      def method_missing(m, *args, &block)
        send(m, *args, &block) unless [:title, :document_id].include?(m)

        # to_s.camelize(:lower) - if we have ActiveSupport as dependency
        field = m.to_s.split('_').inject([]){ |buffer, e| buffer + [buffer.empty? ? e : e.capitalize] }.join
        value = instance_variable_get("@#{m.to_s}") || instance_variable_set("@#{m.to_s}", @data[field])
        value
      end

      # See https://developers.google.com/docs/api/reference/rest/v1/documents/get
      def run_get(document_id)
        return unless @token

        uri_string = "https://docs.googleapis.com/v1/documents/#{document_id}"
        url = URI uri_string

        req = Net::HTTP::Get.new(uri_string)
        req['Authorization'] = "Bearer #{@token}"

        res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
          http.request(req)
        end
        @data.merge! JSON(res.body)
        self
      end

      # See https://developers.google.com/docs/api/reference/rest/v1/documents/create
      def run_create(options = {})
        return unless @token

        uri_string = "https://docs.googleapis.com/v1/documents"
        url = URI uri_string

        req = Net::HTTP::Post.new(uri_string)
        req.initialize_http_header 'Content-Type' => 'application/json'
        req['Authorization'] = "Bearer #{@token}"
        req.body = {title: options[:title]}.to_json

        res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
          http.request(req)
        end
        @data.merge! JSON(res.body)
        self.document_id
      end
    end
  end
end

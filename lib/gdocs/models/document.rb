require 'net/http'
require 'json'

require 'gdocs/concerns/attributes'

module Gdocs
  module Models
    class Document
      attr_writer :data # for testing

      include Concerns::Attributes
      document_attributes :title, :document_id, :revision_id

      def initialize(token)
        if token.to_s.empty?
          raise ArgumentError.new("Auth Token must be present")
        end

        @data = {}
        @token = token
        @end = 0
      end

      # See https://developers.google.com/docs/api/reference/rest/v1/documents/get
      def run_get(document_id)
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
        self
      end

      # See https://developers.google.com/docs/api/reference/rest/v1/documents/request#InsertTextRequest
      def text_to_body(text, font: "Roboto Slab")
        update_body({
          requests: [
            {insertText: {text: text, location: {index: @end + 1}}},
            {updateTextStyle: {textStyle: {weightedFontFamily: {fontFamily: font, weight: 500}},
              fields: "*", range: {startIndex: @end + 1, endIndex: @end + text.length + 1}}}
          ],
          writeControl: {requiredRevisionId: @last_revision_id}
        })
        @end += text.length
      end

      def newline
        update_body({
          requests: [
            {insertText: {text: "\n", location: {index: @end + 1}}},
          ],
          writeControl: {requiredRevisionId: @last_revision_id}
        })
        @end += 1
      end

      def table_to_body(rows, columns)
        update_body({
          requests: [
            {insertTable: {rows: rows, columns: columns, location: {index: @end + 1}}}
          ],
          writeControl: {requiredRevisionId: @last_revision_id}
        })
        @end += 3 + (columns * 2 + 1) * rows
      end

      def update_body(request_body)
        raise Gdocs::Error.new("No data error. Use run_get or run_create method.") if @data.empty?
        @last_revision_id ||= self.revision_id

        uri_string = "https://docs.googleapis.com/v1/documents/#{self.document_id}:batchUpdate"
        url = URI uri_string

        req = Net::HTTP::Post.new(uri_string)
        req.initialize_http_header 'Content-Type' => 'application/json'
        req['Authorization'] = "Bearer #{@token}"
        # "If a segment ID is provided, it must be a header, footer or footnote ID.
        # Use an empty segment ID to reference the body."
        req.body = request_body.to_json

        res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
          http.request(req)
        end
        response_body = JSON(res.body)
        # puts response_body if Gdocs.configuration.log_level == 'development'
        if response_body["error"]
          raise Gdocs::Error.new(response_body["error"]["message"])
        end
        @last_revision_id = response_body["writeControl"]["requiredRevisionId"]
      end
    end
  end
end

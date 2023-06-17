require 'net/http'
require 'json'

require 'gdocs/concerns/attributes'

module Gdocs
  module Models
    class Document
      attr_writer :data # for testing

      include Concerns::Attributes
      document_attributes :title, :document_id, :revision_id

      GOOGLE_DOCS = 'https://docs.googleapis.com/v1/documents'

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
        res = document_get_request("/#{document_id}")
        @data.merge! JSON(res.body)
        self
      end

      # See https://developers.google.com/docs/api/reference/rest/v1/documents/create
      def run_create(options = {})
        # TODO: more option items (or just options.to_json if possible)
        json_string = {title: options[:title]}.to_json

        res = document_post_request("", body: json_string)
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

      # https://developers.google.com/docs/api/reference/rest/v1/documents/request#InsertTableRequest
      def table_to_body(rows, columns)
        update_body({
          requests: [
            {insertTable: {rows: rows, columns: columns, location: {index: @end + 1}}}
          ],
          writeControl: {requiredRevisionId: @last_revision_id}
        })
        @end += 3 + (columns * 2 + 1) * rows
      end

      private

      def update_body(request_body)
        raise Gdocs::Error.new("No data error. Use run_get or run_create method first.") if @data.empty?
        @last_revision_id ||= self.revision_id

        json_string = request_body.to_json
        res = document_post_request("/#{self.document_id}:batchUpdate", body: json_string)
        response_body = JSON(res.body)

        # puts response_body if Gdocs.configuration.log_level == 'development'
        if response_body["error"]
          raise Gdocs::Error.new(response_body["error"]["message"])
        end
        @last_revision_id = response_body["writeControl"]["requiredRevisionId"]
      end

      def document_post_request(url_path, body: "{}")
        uri = URI(GOOGLE_DOCS + url_path)

        req = Net::HTTP::Post.new(uri.to_s)
        req.initialize_http_header 'Content-Type' => 'application/json'
        req['Authorization'] = "Bearer #{@token}"

        req.body = body

        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          http.request(req)
        end
      end

      def document_get_request(url_path)
        uri = URI(GOOGLE_DOCS + url_path)

        req = Net::HTTP::Get.new(uri.to_s)
        req['Authorization'] = "Bearer #{@token}"

        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          http.request(req)
        end
      end
    end
  end
end

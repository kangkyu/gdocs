require 'net/http'
require 'json'

require 'gdocs/concerns/attributes'
require 'gdocs/concerns/requests'

module Gdocs
  module Models
    class Document
      attr_writer :data # for testing only

      include Concerns::Attributes
      document_attributes :title, :document_id, :revision_id

      GOOGLE_DOCS = 'https://docs.googleapis.com/v1/documents'
      include Concerns::Requests

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
        response_body = document_get_request("/#{document_id}")
        @data.merge! response_body
        @end = @data["body"]["content"][-1]["endIndex"] - 1
        self
      end

      # See https://developers.google.com/docs/api/reference/rest/v1/documents/create
      def run_create(options = {})
        # TODO: more option items (or just options.to_json if possible)
        request_body = {title: options[:title]}

        response_body = document_post_request("", body: request_body)
        @data.merge! response_body
        @end = @data["body"]["content"][-1]["endIndex"] - 1
        self
      end

      # See https://developers.google.com/docs/api/reference/rest/v1/documents/request#InsertTextRequest
      def text_to_body(text, font: "Roboto Slab")
        update_body({
          requests: [
            {insertText: {text: text, location: {index: @end}}},
            {updateTextStyle: {textStyle: {weightedFontFamily: {fontFamily: font, weight: 500}},
              fields: "*", range: {startIndex: @end, endIndex: @end + text.length}}}
          ],
          writeControl: {requiredRevisionId: @last_revision_id}
        })
        @end += text.length
      end

      def newline
        update_body({
          requests: [
            {insertText: {text: "\n", location: {index: @end}}},
          ],
          writeControl: {requiredRevisionId: @last_revision_id}
        })
        @end += 1
      end

      # https://developers.google.com/docs/api/reference/rest/v1/documents/request#InsertTableRequest
      def table_to_body(rows, columns)
        update_body({
          requests: [
            {insertTable: {rows: rows, columns: columns, location: {index: @end}}}
          ],
          writeControl: {requiredRevisionId: @last_revision_id}
        })
        @end += 3 + (columns * 2 + 1) * rows
      end

      private

      def update_body(request_body)
        if @data.empty?
          raise Gdocs::Error.new("No data error. Use run_get or run_create method first.")
        end

        @last_revision_id ||= self.revision_id

        url_path = "/#{self.document_id}:batchUpdate"
        response_body = document_post_request(url_path, body: request_body)

        # "If a segment ID is provided, it must be a header, footer or footnote ID.
        # Use an empty segment ID to reference the body."

        @last_revision_id = response_body["writeControl"]["requiredRevisionId"]
      end

      def document_post_request(url_path, body: {})
        uri = URI(GOOGLE_DOCS + url_path)

        res = post_request(uri, auth_token: @token, body: body.to_json)
        response_body = JSON(res.body)

        if response_body["error"]
          raise Gdocs::Error.new(response_body["error"]["message"])
        end
        response_body
      end

      def document_get_request(url_path)
        uri = URI(GOOGLE_DOCS + url_path)

        res = get_request(uri, auth_token: @token)
        JSON(res.body)
      end
    end
  end
end

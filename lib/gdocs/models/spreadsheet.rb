require 'net/http'
require 'json'

require 'gdocs/concerns/requests'

module Gdocs
  module Models
    class Spreadsheet
      GOOGLE_SHEETS = "https://sheets.googleapis.com/v4/spreadsheets"
      include Concerns::Requests

      def initialize(token)
        if token.to_s.empty?
          raise ArgumentError.new("Auth Token must be present")
        end

        @token = token
        @data = {}
      end

      # https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create
      def run_create(options = {})
        request_body = {
          sheets: [
            {
              charts: [
                {
                  spec: {
                    title: options[:title],
                    basicChart: {
                      chartType: "BAR"
                    }
                  }
                }
              ]
            }
          ]
        }
        response_body = spreadsheet_post_request("", body: request_body)

        puts response_body if Gdocs.configuration.log_level == 'development'
        @data.merge! response_body
        self
      end

      # https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get
      def run_get(spreadsheet_id)
        response_body = spreadsheet_get_request("/#{spreadsheet_id}")
        @data.merge! response_body
        self
      end

      def spreadsheet_get_request(url_path)
        uri = URI(GOOGLE_SHEETS + url_path)

        res = get_request(uri, auth_token: @token)
        JSON(res.body)
      end

      def spreadsheet_post_request(url_path, body: {})
        uri = URI(GOOGLE_SHEETS + url_path)

        res = post_request(uri, auth_token: @token, body: body.to_json)
        response_body = JSON(res.body)

        if response_body["error"]
          raise Gdocs::Error.new(response_body["error"]["message"])
        end
        response_body
      end
    end
  end
end

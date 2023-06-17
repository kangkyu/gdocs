require 'net/http'
require 'json'

module Gdocs
  module Models
    class Spreadsheet
      GOOGLE_SHEETS = "https://sheets.googleapis.com/v4/spreadsheets"

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

      def spreadsheet_post_request(url_path, body: {})
        uri = URI(GOOGLE_SHEETS + url_path)

        req = Net::HTTP::Post.new(uri.to_s)
        req.initialize_http_header 'Content-Type' => 'application/json'
        req['Authorization'] = "Bearer #{@token}"

        req.body = body.to_json

        res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          http.request(req)
        end

        response_body = JSON(res.body)

        if response_body["error"]
          raise Gdocs::Error.new(response_body["error"]["message"])
        end
        response_body
      end
    end
  end
end

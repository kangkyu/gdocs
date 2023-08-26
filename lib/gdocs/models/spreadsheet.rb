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
      def run_create(json_string)
        spreadsheet_title = "I want a chart 4"
        sheet_title = "hola 4"

        # options = {"female"=>{"13-17"=>1.4, "18-24"=>6.9, "25-34"=>21.2, "35-44"=>19.6, "45-54"=>15, "55-64"=>5.2, "65-"=>0.9}, "male"=>{"13-17"=>1, "18-24"=>4.8, "25-34"=>12.7, "35-44"=>7.7, "45-54"=>2.3, "55-64"=>0.6, "65-"=>0.6}}
        # json_string = %q{{"female": {"13-17": 1.4, "18-24": 6.9, "25-34": 21.2, "35-44": 19.6, "45-54": 15, "55-64": 5.2, "65-": 0.9}, "male": {"13-17": 1, "18-24": 4.8, "25-34": 12.7, "35-44": 7.7, "45-54": 2.3, "55-64": 0.6, "65-": 0.6}}}
        input = JSON(json_string)

        headers = input.keys.unshift("").map do |key|
          {userEnteredValue: {stringValue: key}}
        end
        h = {}
        keys = input.values.map(&:keys).flatten.uniq
        keys.each do |key|
          input.values.each do |pair|
            h[key] ||= []
            h[key].push(pair[key])
          end
        end
        row_data = h.map do |key, values|
          rows = values.map do |i|
            {userEnteredValue: {numberValue: i}}
          end.unshift({userEnteredValue: {stringValue: key}})
          {values: rows}
        end.unshift({values: headers})

        request_body = {
          properties: {
            title: spreadsheet_title,
            locale: "en_US",
            autoRecalc: "ON_CHANGE"
          },
          sheets: [
            {
              properties: {
                title: sheet_title
              },
              data: [
                {
                  rowData: row_data
                }
              ]
            }
          ]
        }
        response_body = spreadsheet_post_request("", body: request_body)

        puts response_body if Gdocs.configuration.log_level == 'development'
        @data.merge! response_body

        run_update(input.keys.size, keys.size)
        self
      end

      # https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/batchUpdate
      def run_update(x, y)
        spreadsheet_id = @data["spreadsheetId"]
        sheet_id = @data["sheets"][0]["properties"]["sheetId"]

        series = 1.upto(x).map do |num|
          {series: {sourceRange: {sources: [
            {
              sheetId: sheet_id,
              startRowIndex: 0,
              endRowIndex: y - 1,
              startColumnIndex: num,
              endColumnIndex: num + 1
            }
          ]}},
          targetAxis: "LEFT_AXIS"}
        end

        domains = [
          {series: {sourceRange: {sources: [
            {
              sheetId: sheet_id,
              startRowIndex: 0,
              endRowIndex: y - 1,
              startColumnIndex: 0,
              endColumnIndex: 1
            }
          ]}}}
        ]

        bottom_title = "Age Groups"
        left_title = "Views"

        axis = [
                {
                  position: "BOTTOM_AXIS",
                  title: bottom_title
                },
                {
                  position: "LEFT_AXIS",
                  title: left_title
                }
              ]

        chart_title = "Demographics"

        request_body = {
          requests: [
            {
              addChart: {
                chart: {
                  spec: {
                    title: chart_title,
                    basicChart: {
                      chartType: "COLUMN",
                      legendPosition: "BOTTOM_LEGEND",
                      axis: axis,
                      domains: domains,
                      series: series,
                      headerCount: 1
                    }
                  },
                  position: {
                    newSheet: true
                  }
                }
              }
            }
          ]
        }
        response_body = spreadsheet_post_request("/#{spreadsheet_id}:batchUpdate", body: request_body)

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

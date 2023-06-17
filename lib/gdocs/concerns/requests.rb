module Gdocs
  module Concerns
    module Requests
      def get_request(uri, auth_token: "")
        req = Net::HTTP::Get.new(uri.to_s)
        req['Authorization'] = "Bearer #{auth_token}"

        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          http.request(req)
        end
      end

      def post_request(uri, auth_token: "", body: "")
        req = Net::HTTP::Post.new(uri.to_s)
        req.initialize_http_header 'Content-Type' => 'application/json'
        req['Authorization'] = "Bearer #{auth_token}"

        req.body = json_body

        res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          http.request(req)
        end
      end
    end
  end
end

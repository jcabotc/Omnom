require "net/http"
require "base64"
require "json"

require "omnom/adapter/google_pubsub/received"
require "omnom/adapter/google_pubsub/request_error"

class Omnom
  module Adapter
    class GooglePubsub
      def initialize(opts)
        host = opts.fetch(:host, "https://pubsub.googleapis.com")
        port = opts.fetch(:port, 80)
        project_id = opts.fetch(:project_id)
        subscription = opts.fetch(:subscription)
        token = opts.fetch(:token)

        @http = Net::HTTP.new(host, port)
        @base_path = "/v1/projects/#{project_id}/subscriptions/#{subscription}"
        @headers = {"authorization" => "Bearer #{token}", "content-type" => "application/json"}
      end

      def fetch(demand)
        body = request("pull", {"maxMessages" => demand})

        JSON.parse(body).fetch("receivedMessages").map do |raw_message|
          ack_id = raw_message.fetch("ackId")

          encoded = raw_message.fetch("message").fetch("data")
          message = Base64.decode64(encoded)

          Received.new(message, ack_id, self)
        end
      end

      def ack(ack_id)
        request("acknowledge", {"ackIds" => [ack_id]})
        true
      end

      def no_ack(ack_id)
        request("modifyAckDeadline", {"ackIds" => [ack_id], "ackDeadlineSeconds" => 0})
        true
      end

      private

      def request(action, content)
        path = "#{base_path}:#{action}"
        body = content.to_json

        response = http.send_request("POST", path, body, headers)

        if response.code == "200"
          response.body
        else
          raise RequestError.new("POST", path, body, headers, response)
        end
      end

      attr_reader :http, :base_path, :headers
    end
  end
end

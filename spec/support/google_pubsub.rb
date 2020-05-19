require "net/http"
require "base64"
require "json"
require "securerandom"

module Support
  class GooglePubsub
    attr_reader :opts

    def initialize
      @opts = {
        host: "localhost",
        port: 8085,
        project_id: "project_id_#{SecureRandom.hex(8)}",
        subscription: "subscription_#{SecureRandom.hex(8)}",
        token: "token_#{SecureRandom.hex(8)}"
      } 

      topic = "topic_#{SecureRandom.hex(8)}"

      @full_topic = "projects/#{opts[:project_id]}/topics/#{topic}"
      @full_subscription = "projects/#{opts[:project_id]}/subscriptions/#{opts[:subscription]}"

      @http = Net::HTTP.new(opts[:host], opts[:port])
      @headers = {"authorization" => "Bearer #{opts[:token]}", "content-type" => "application/json"}

      declare_topic_and_subscription
    end

    def publish(data)
      encoded = Base64.encode64(data).delete_suffix("\n")
      body = {"messages" => [{"data" => encoded}]}.to_json

      request("POST", "/v1/#{full_topic}:publish", body)
    end

    private

    def declare_topic_and_subscription
      request("PUT", "/v1/#{full_topic}", "")
      request("PUT", "/v1/#{full_subscription}", {"topic" => full_topic}.to_json)
    end

    def request(verb, path, body)
      response = http.send_request(verb, path, body, headers)

      if response.code != "200"
        raise "Unexpected status: #{response.code} (#{response.body})"
      end
    end

    attr_reader :http, :full_topic, :full_subscription, :headers
  end
end

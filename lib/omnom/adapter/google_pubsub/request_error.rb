class Omnom
  module Adapter
    class GooglePubsub
      class RequestError < StandardError
        attr_reader :verb, :uri, :body, :headers, :response

        def initialize(verb, uri, body, headers, response)
          @verb = verb
          @uri = uri
          @body = body
          @headers = headers
          @response = response
        end
      end
    end
  end
end

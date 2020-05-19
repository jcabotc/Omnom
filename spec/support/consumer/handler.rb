require 'concurrent'

module Support
  module Consumer
    class Handler
      attr_reader :received_messages

      def initialize
        @received_messages = Concurrent::Array.new
      end

      def handle(message)
        received_messages.push(message)
      end
    end
  end
end

require "concurrent"

module Support
  class TestAdapter
    class Received
      attr_reader :message

      def initialize(message, adapter)
        @message = message
        @adapter = adapter
      end

      def ack
        adapter.ack(message)
      end

      def no_ack
        adapter.no_ack(message)
      end

      private

      attr_reader :adapter
    end

    attr_reader :messages, :acks, :no_acks

    def initialize(messages)
      @messages = Concurrent::Array.new(messages.to_a)
      @acks = Concurrent::Array.new
      @no_acks = Concurrent::Array.new
    end

    def fetch(demand)
      messages.shift(demand).map do |message|
        Received.new(message, self)
      end
    end

    def ack(message)
      acks.push(message)
    end

    def no_ack(message)
      no_acks.push(message)
      messages.unshift(message)
    end

    private

    attr_accessor :messages
  end
end

require 'concurrent'

module Omnom
  class Producer
    class Subscription
      attr_reader :demand

      def initialize(demand)
        @demand = demand
        @buffer = Concurrent::Array.new
      end

      def full?
        demand <= buffer.size
      end

      def missing
        demand - buffer.size
      end

      def push(messages)
        buffer.push(*messages)
      end

      def pop
        buffer.shift
      end

      private

      attr_reader :buffer
    end
  end
end

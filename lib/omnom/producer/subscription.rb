require 'concurrent'

module Omnom
  class Producer
    class Subscription
      attr_reader :demand

      def initialize(demand)
        @demand = demand
        @queue = Concurrent::Array.new
        @blocked_pop = nil
      end

      def full?
        demand <= queue.size
      end

      def missing
        demand - queue.size
      end

      def push(messages)
        queue.push(*messages)

        maybe_unblock_pop
      end

      def pop
        block_until_pushed if queue.empty?

        queue.shift
      end

      private

      def block_until_pushed
        self.blocked_pop = Concurrent::Promises.resolvable_future()
        blocked_pop.wait
      end

      def maybe_unblock_pop
        if blocked_pop
          blocked_pop.resolve
          self.blocked_pop = nil
        end
      end

      attr_reader :queue
      attr_accessor :blocked_pop
    end
  end
end

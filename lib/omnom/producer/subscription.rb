require 'concurrent'

module Omnom
  class Producer
    class Subscription
      attr_reader :demand

      def initialize(demand)
        @demand = demand
        @queue = Concurrent::Array.new
        @blocked_pop = nil
        @terminating = false
      end

      def missing
        demand - queue.size
      end

      def push(messages)
        queue.push(*messages)
        maybe_unblock_pop
      end

      def pop
        blocking_pop if not terminated?
      end

      def terminate
        self.terminating = true
        maybe_unblock_pop
      end

      def terminated?
        terminating and queue.empty?
      end

      private

      def blocking_pop
        block_until_pushed if queue.empty?
        queue.shift
      end

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
      attr_accessor :blocked_pop, :terminating
    end
  end
end

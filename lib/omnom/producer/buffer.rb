require 'concurrent'

module Omnom
  class Producer
    class Buffer
      def initialize(size)
        @max_size = size
        @queue = Concurrent::Array.new
        @waiting = Concurrent::Array.new
        @terminating = false
      end

      def missing
        max_size - queue.size
      end

      def push_many(messages)
        futures = waiting.shift(messages.size)
        futures.each { |future| future.fulfill(messages.shift) }

        queue.push(*messages)
      end

      def pop
        message = queue.shift
        message.nil? ? maybe_wait : message
      end

      def terminate
        self.terminating = true
      end

      private

      def maybe_wait
        if not terminated?
          future = Concurrent::Promises.resolvable_future
          waiting.push(future)

          future.value
        end
      end

      def terminated?
        terminating and queue.empty?
      end

      attr_reader :max_size, :queue, :waiting
      attr_accessor :terminating
    end
  end
end

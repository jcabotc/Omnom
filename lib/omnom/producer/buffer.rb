require 'concurrent'

module Omnom
  class Producer
    class Buffer
      def initialize(size)
        @size = size
        @queue = Concurrent::Array.new
        @waiting = Concurrent::Array.new
        @terminating = Concurrent::AtomicBoolean.new(false)
      end

      def missing
        size - queue.size
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
        terminating.make_true
        waiting.each { |future| future.fulfill(nil) }
      end

      private

      def maybe_wait
        if terminating.false?
          future = Concurrent::Promises.resolvable_future
          waiting.push(future)

          future.value
        end
      end

      attr_reader :size, :queue, :waiting, :terminating
    end
  end
end

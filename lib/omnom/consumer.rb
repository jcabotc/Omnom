require "omnom/consumer/stream"

class Omnom
  class Consumer
    def initialize(producer, config)
      @stream = Stream.new(producer)
      @handler = config.handler
      @thread = Thread.new { consume }
    end

    def wait_for_termination
      thread.join
    end

    private

    def consume
      stream.each do |received|
        if safe_handle(received.message)
          received.ack
        else
          received.no_ack
        end
      end
    end

    def safe_handle(message)
      handler.handle(message)
    rescue StandardError => e
      # handle error
      false
    end

    attr_reader :stream, :handler, :thread
  end
end

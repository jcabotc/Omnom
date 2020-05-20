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
          safe_ack(received)
        else
          safe_no_ack(received)
        end
      end
    end

    def safe_handle(message)
      handler.handle(message)
    rescue StandardError => e
      # TODO: Report error
      false
    end

    def safe_ack(received)
      received.ack
    rescue StandardError => e
      # TODO: Report error
    end

    def safe_no_ack(received)
      received.no_ack
    rescue StandardError => e
      # TODO: Report error
    end

    attr_reader :stream, :handler, :thread
  end
end

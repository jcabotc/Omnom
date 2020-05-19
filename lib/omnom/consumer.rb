require "omnom/consumer/stream"

module Omnom
  class Consumer
    def initialize(producer, config)
      @stream = Stream.new(producer)
      @handler = config.handler

      Thread.new { consume }
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

    attr_reader :stream, :handler
  end
end

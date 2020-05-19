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
        safe_handle(received.message)
      end
    end

    def safe_handle(message)
      handler.handle(message)
    rescue StandardError => e
      # handle error
    end

    attr_reader :stream, :handler
  end
end

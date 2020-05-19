module Omnom
  class Producer
    class Config
      DEFAULT_BUFFER_SIZE = 100
      DEFAULT_POLL_INTERVAL_MS = 250

      attr_reader :adapter, :buffer_size, :poll_interval_ms

      def initialize(raw_config)
        @adapter = raw_config.fetch(:adapter)
        @buffer_size = raw_config.fetch(:buffer_size, DEFAULT_BUFFER_SIZE)
        @poll_interval_ms = raw_config.fetch(:poll_interval_ms, DEFAULT_POLL_INTERVAL_MS)
      end
    end
  end
end

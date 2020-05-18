module Omnom
  class Producer
    class Config
      DEFAULT_POLL_INTERVAL_MS = 1000

      attr_reader :poll_interval_ms, :adapter

      def initialize(raw_config)
        @poll_interval_ms = raw_config.fetch(:poll_interval_ms, DEFAULT_POLL_INTERVAL_MS)
        @adapter = raw_config.fetch(:adapter)
      end
    end
  end
end

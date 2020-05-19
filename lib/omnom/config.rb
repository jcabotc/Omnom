module Omnom
  class Config
    DEFAULTS = {
      buffer_size: 100,
      poll_interval_ms: 250
    }

    attr_reader :adapter, :buffer_size, :poll_interval_ms

    def initialize(opts)
      @adapter = opts.fetch(:adapter)
      @buffer_size = opts.fetch(:buffer_size, DEFAULT[:buffer_size])
      @poll_interval_ms = opts.fetch(:poll_interval_ms, DEFAULT[:poll_interval_ms])
    end
  end
end

class Omnom
  class Config
    def initialize(raw_config)
      @raw_config = raw_config
    end

    def adapter
      raw_config.fetch(:adapter)
    end

    def handler
      raw_config.fetch(:handler)
    end

    def buffer_size
      raw_config.fetch(:buffer_size, 100)
    end

    def poll_interval_ms
      raw_config.fetch(:poll_interval_ms, 250)
    end

    def concurrency
      raw_config.fetch(:concurrency, 20)
    end

    private

    attr_reader :raw_config
  end
end

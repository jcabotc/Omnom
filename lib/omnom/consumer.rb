require 'concurrent'

require 'omnom/consumer/config'

module Omnom
  class Consumer
    attr_reader :config

    def initialize(config)
      @pool = start_pool(config)
      @handler = config.handler
    end

    def handle(message)
      pool.post(message) do |message|
        safe_handle(message)
      end
    end

    def stop
      pool.shutdown
    end

    private

    def safe_handle(message)
      handler.handle(message)
    rescue StandardError => e
      # handle error
    end

    def start_pool(config)
      Concurrent::FixedThreadPool.new(config.pool_size)
    end

    attr_reader :pool, :handler
  end
end

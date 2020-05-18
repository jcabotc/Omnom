module Omnom
  class Consumer
    class Config
      DEFAULT_POOL_SIZE = 4

      attr_reader :pool_size, :handler

      def initialize(raw_config)
        @pool_size = raw_config.fetch(:pool_size, DEFAULT_POOL_SIZE)
        @handler = raw_config.fetch(:handler)
      end
    end
  end
end

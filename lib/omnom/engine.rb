module Omnom
  class Engine
    def initialize(config)
      @producer = Producer.new(config)
      @consumers = start_consumers(config)
    end

    def stop
      producer.stop
      consumers.each(&:wait_for_termination)
    end

    private

    def start_consumers(config)
      amount = config.concurrency
      amount.times.map { Consumer.new(producer, config) }
    end

    attr_reader :producer, :consumers
  end
end

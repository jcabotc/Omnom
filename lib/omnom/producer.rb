require 'concurrent'
require 'omnom/producer/config'
require 'omnom/producer/subscription'

module Omnom
  class Producer
    def initialize(config)
      @adapter = config.adapter
      @subscriptions = Concurrent::Array.new

      start_timer_task(config)
    end

    def subscribe(demand)
      Subscription.new(demand).tap do |subscription|
        subscriptions.push(subscription)
      end
    end

    def unsubscribe(subscription)
      subscriptions.delete(subscription)
    end
    
    private

    def start_timer_task(config)
      interval = config.poll_interval_ms / 1000.0

      task = Concurrent::TimerTask.new(execution_interval: interval) { handle_demand }
      task.execute
    end

    def handle_demand
      missing = subscriptions.map(&:missing).reduce(0, &:+)

      if missing > 0
        messages = safe_fetch(missing)

        spread_between_subscriptions(messages)
      end
    end

    def safe_fetch(missing)
      adapter.fetch(missing)
    rescue StandardError => e
      # handle error
      []
    end

    def spread_between_subscriptions(messages)
      subscriptions.shuffle.each do |subscription|
        missing = subscription.missing
        popped_messages = messages.pop(missing)
        
        subscription.push(popped_messages)
      end
    end

    attr_reader :adapter, :subscriptions
  end
end

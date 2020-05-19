require 'concurrent'

require 'omnom/producer/buffer'

module Omnom
  class Producer
    def initialize(config)
      @adapter = config.adapter
      @buffer = Buffer.new(config.buffer_size)
      @recurring_task = build_recurring_task_to_fill_buffer(config)

      recurring_task.execute
    end

    def pop
      buffer.pop
    end

    def stop
      recurring_task.shutdown
      buffer.terminate
    end

    private

    def build_recurring_task_to_fill_buffer(config)
      interval_s = config.poll_interval_ms / 1000.0

      Concurrent::TimerTask.new(execution_interval: interval_s) { fill_buffer }
    end

    def fill_buffer
      if buffer.missing > 0
        messages = safe_fetch(buffer.missing)

        buffer.push_many(messages)
      end
    end

    def safe_fetch(missing)
      adapter.fetch(missing)
    rescue StandardError => e
      # handle error
      []
    end

    attr_reader :adapter, :buffer, :recurring_task
  end
end

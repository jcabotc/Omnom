require 'concurrent'

require 'omnom/producer/buffer'

module Omnom
  class Producer
    def initialize(config)
      @adapter = config.adapter
      @buffer = Buffer.new(config.buffer_size)

      start_recurring_task_to_fill_buffer(config)
    end

    def pop
      buffer.pop
    end

    def stop
      buffer.terminate
    end

    private

    def start_recurring_task_to_fill_buffer(config)
      interval_s = config.poll_interval_ms / 1000.0

      task = Concurrent::TimerTask.new(execution_interval: interval_s) { fill_buffer }
      task.execute
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

    attr_reader :adapter, :buffer
  end
end

require 'concurrent'

module Support
  class TestHandler
    attr_reader :received_messages

    def initialize
      @received_messages = Concurrent::Array.new
    end

    def handle(message)
      received_messages.push(message)
      true
    end
  end
end

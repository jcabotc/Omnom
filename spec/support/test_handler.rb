require 'concurrent'

module Support
  class TestHandler
    attr_reader :received_messages

    def initialize
      @received_messages = Concurrent::Array.new
      @messages_to_return_false = Concurrent::Array.new
      @messages_to_raise = Concurrent::Array.new
    end

    def return_false_on(message)
      messages_to_return_false.push(message)
    end

    def raise_on(message)
      messages_to_raise.push(message)
    end

    def handle(message)
      received_messages.push(message)

      if messages_to_return_false.delete(message)
        false
      elsif messages_to_raise.delete(message)
        raise "Simulated crash"
      else
        true
      end
    end

    private

    attr_reader :messages_to_return_false, :messages_to_raise
  end
end

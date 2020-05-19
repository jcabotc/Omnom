module Support
  class TestProducer
    def initialize(messages)
      @adapter = TestAdapter.new(messages)
    end

    def pop
      adapter.fetch(1).first
    end

    def messages
      adapter.messages
    end

    def acks
      adapter.acks
    end

    def no_acks
      adapter.no_acks
    end

    private

    attr_reader :adapter
  end
end

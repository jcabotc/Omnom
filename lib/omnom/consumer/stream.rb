class Omnom
  class Consumer
    class Stream
      include Enumerable

      def initialize(producer)
        @producer = producer
      end

      def each
        while message = producer.pop do
          yield message
        end
      end

      private

      attr_reader :producer
    end
  end
end

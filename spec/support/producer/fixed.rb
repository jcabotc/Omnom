module Support
  module Producer
    class Fixed
      def initialize(messages)
        @messages = messages
      end

      def pop
        messages.shift
      end

      private

      attr_accessor :messages
    end
  end
end

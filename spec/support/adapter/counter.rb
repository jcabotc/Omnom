module Support
  module Adapter
    class Counter
      def initialize(initial = 0)
        @count = initial
      end

      def fetch(demand)
        old_count = count
        self.count += demand

        ((old_count + 1)..count).to_a
      end

      private

      attr_accessor :count
    end
  end
end

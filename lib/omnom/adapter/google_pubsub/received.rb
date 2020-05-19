class Omnom
  module Adapter
    class GooglePubsub
      class Received
        attr_reader :message

        def initialize(message, ack_id, adapter)
          @message = message
          @ack_id = ack_id
          @adapter = adapter
        end

        def ack
          adapter.ack(ack_id)
        end

        def no_ack
          adapter.no_ack(ack_id)
        end

        private

        attr_reader :ack_id, :adapter
      end
    end
  end
end

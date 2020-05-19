RSpec.describe Omnom::Consumer do
  let(:messages) { [:message_1, :message_2, :message_3] }
  let(:producer) { Support::TestProducer.new(messages) }

  let(:handler) { Support::TestHandler.new() }
  let(:config) { Omnom::Config.new(handler: handler) }

  subject { described_class.new(producer, config) }

  describe "asynchronous messages consumption" do
    it "happy path" do
      subject
      sleep(0.1) # wait for the consumer to consume all messages

      expect(handler.received_messages).to eq messages

      expect(producer.acks).to eq messages
      expect(producer.no_acks).to eq []
    end

    it "retries if handler returns false" do
      handler.return_false_on(:message_2)

      subject
      sleep(0.1) # wait for the consumer to consume all messages

      expected_messages = messages + [:message_2]
      expect(handler.received_messages).to match_array expected_messages

      expect(producer.acks).to eq messages
      expect(producer.no_acks).to eq [:message_2]
    end

    it "retries if handler raises" do
      handler.raise_on(:message_3)

      subject
      sleep(0.1) # wait for the consumer to consume all messages

      expected_messages = messages + [:message_3]
      expect(handler.received_messages).to match_array expected_messages

      expect(producer.acks).to eq messages
      expect(producer.no_acks).to eq [:message_3]
    end
  end
end

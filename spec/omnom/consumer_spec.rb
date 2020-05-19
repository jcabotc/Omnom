RSpec.describe Omnom::Consumer do
  let(:messages) { [:message_1, :message_2, :message_3] }
  let(:producer) { Support::TestProducer.new(messages) }

  let(:handler) { Support::TestHandler.new() }
  let(:config) { Omnom::Config.new(handler: handler) }

  subject { described_class.new(producer, config) }

  it "asynchronously consumes messages" do
    subject

    # wait for the consumer to consume all messages
    sleep(0.1)

    expect(handler.received_messages).to eq messages
  end
end

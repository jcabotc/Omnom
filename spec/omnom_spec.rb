RSpec.describe Omnom do
  let(:adapter) { Support::TestAdapter.new(1..200) }
  let(:handler) { Support::TestHandler.new() }
  let(:buffer_size) { 25 }
  let(:poll_interval_ms) { 5 }
  let(:concurrency) { 4 }

  let :config do
    Omnom::Config.new(
      adapter: adapter,
      handler: handler,
      buffer_size: buffer_size,
      poll_interval_ms: poll_interval_ms,
      concurrency: concurrency
    )
  end

  subject { described_class.new(config) }

  describe "start and stop" do
    it "consumes all messages properly" do
      subject

      sleep(0.5)
      # Wait for the engine to process all messages

      subject.stop
      expect(handler.received_messages).to match_array (1..200).to_a
    end
  end
end

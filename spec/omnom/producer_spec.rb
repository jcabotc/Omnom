RSpec.describe Omnom::Producer do
  let(:poll_interval_ms) { 50 }
  let(:adapter) { Support::Adapter::Counter.new }

  let :config do
    described_class::Config.new(
      poll_interval_ms: poll_interval_ms,
      adapter: adapter
    )
  end

  subject { described_class.new(config) }

  describe "#subscribe and demand handling" do
    it "fills demand for all subscriptions" do
      subscription_1 = subject.subscribe(1)
      subscription_2 = subject.subscribe(2)

      sleep(0.1)
      expect(subscription_1.missing).to eq 0
      expect(subscription_2.missing).to eq 0

      value_1 = subscription_1.pop
      value_2 = subscription_2.pop

      expect([1, 2, 3]).to include(value_1)
      expect([1, 2, 3]).to include(value_2)

      sleep(0.1)
      expect(subscription_1.missing).to eq 0 
      expect(subscription_2.missing).to eq 0 

      values = [
        value_1,
        value_2,
        subscription_1.pop,
        subscription_2.pop,
        subscription_2.pop
      ]

      expect(values).to match_array [1, 2, 3, 4, 5]
    end
  end

  describe "#unsubscribe" do
    it "stops pushing messages to the subscription" do
      subscription = subject.subscribe(1)

      sleep(0.1)
      expect(subscription.missing).to eq 0 

      subject.unsubscribe(subscription)
      subscription.pop

      sleep(0.1)
      expect(subscription.missing).to eq 1 
      expect(subscription.terminated?).to eq true
    end
  end
end

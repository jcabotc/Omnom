RSpec.describe Omnom::Producer do
  let :counter_class do
    Struct.new(:count) do
      def fetch(demand)
        old_count = count
        self.count += demand

        ((old_count + 1)..count).to_a
      end
    end
  end

  let(:poll_interval_ms) { 50 }
  let(:adapter) { counter_class.new(0) }

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
      expect(subscription_1.full?).to eq true
      expect(subscription_2.full?).to eq true

      value_1 = subscription_1.pop
      value_2 = subscription_2.pop

      expect([1, 2, 3]).to include(value_1)
      expect([1, 2, 3]).to include(value_2)

      sleep(0.1)
      expect(subscription_1.full?).to eq true
      expect(subscription_2.full?).to eq true

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
      expect(subscription.full?).to eq true

      subject.unsubscribe(subscription)
      subscription.pop

      sleep(0.1)
      expect(subscription.full?).to eq false
    end
  end
end

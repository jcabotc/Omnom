RSpec.describe Omnom::Producer::Subscription do
  let(:demand) { 5 }

  subject { described_class.new(demand) }

  describe "#push and #pop" do
    it "#pop returns messages in the order they were pushed" do
      subject.push([:message_1])
      subject.push([:message_2, :message_3])

      expect(subject.pop).to eq :message_1
      expect(subject.pop).to eq :message_2

      subject.push([:message_4])

      expect(subject.pop).to eq :message_3
      expect(subject.pop).to eq :message_4
    end

    context "when there are no messages" do
      it "#pop blocks until a message is pushed (unless terminating)" do
        thread = Thread.new { subject.pop }

        sleep(0.01)
        expect(thread.alive?).to eq true

        subject.push([:message_1])
        expect(thread.value).to eq :message_1
        expect(thread.alive?).to eq false
      end

      it "when terminating #pop returns nil instead of blocking" do
        subject.terminate

        expect(subject.pop).to eq nil
      end
    end
  end

  describe "#missing" do
    let(:demand) { 3 }

    it "returns the number of messages needed to fill the queue" do
      expect(subject.missing).to eq 3

      subject.push([:message_1])
      expect(subject.missing).to eq 2

      subject.push([:message_2, :message_3])
      expect(subject.missing).to eq 0

      subject.pop
      expect(subject.missing).to eq 1
    end
  end
end

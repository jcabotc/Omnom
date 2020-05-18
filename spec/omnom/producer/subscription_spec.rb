RSpec.describe Omnom::Producer::Subscription do
  subject { described_class.new(demand) }

  describe "push and pop flow" do
    let(:demand) { 3 }

    it "works as expected" do
      expect(subject.missing).to eq 3
      expect(subject.full?).to eq false

      subject.push([:message_1])
      expect(subject.missing).to eq 2

      subject.push([:message_2, :message_3])
      expect(subject.missing).to eq 0
      expect(subject.full?).to eq true

      expect(subject.pop).to eq :message_1
      expect(subject.pop).to eq :message_2
      expect(subject.pop).to eq :message_3

      thread = Thread.new { subject.pop }

      sleep(0.1)
      expect(thread.alive?).to eq true

      subject.push([:message_4])
      expect(thread.value).to eq :message_4
      expect(thread.alive?).to eq false
    end
  end
end

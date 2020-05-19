RSpec.describe Omnom::Adapter::GooglePubsub do
  # This test depends on google pubsub emulator being started locally
  # with the default configuration.
  # It is excluded by default.
  # Run it with: `rspec --tag google_pubsub`

  let(:helper) { Support::GooglePubsub.new }
  
  subject { described_class.new(helper.opts) }

  describe "message lifecycle" do
    it "on no_ack the message is fetched again", google_pubsub: true do
      helper.publish("data_1")
      helper.publish("data_2")
      helper.publish("data_3")

      receiveds = subject.fetch(2)
      expect(receiveds.size).to eq 2

      received_1, received_2 = receiveds
      expect(received_1.message).to eq "data_1"
      expect(received_2.message).to eq "data_2"

      received_1.ack
      received_2.no_ack

      receiveds = subject.fetch(3)
      expect(receiveds.size).to eq 2

      expect(receiveds.map(&:message)).to match_array ["data_2", "data_3"]
      receiveds.each(&:ack)
    end
  end
end

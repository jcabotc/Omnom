require 'concurrent'

RSpec.describe Omnom::Consumer do
  it "asynchronously consumes messages" do
    handler = Module.new do
      def handle(message)
        message[:ivar].set("done")
      end

      module_function :handle
    end

    config = described_class::Config.new(pool_size: 2, handler: handler)
    consumer = described_class.new(config)

    ivar_1 = Concurrent::IVar.new
    ivar_2 = Concurrent::IVar.new
    ivar_3 = Concurrent::IVar.new

    consumer.handle({ivar: ivar_1})
    consumer.handle({ivar: ivar_2})
    consumer.handle({ivar: ivar_3})

    expect(ivar_1.value).to eq "done"
    expect(ivar_2.value).to eq "done"
    expect(ivar_3.value).to eq "done"

    consumer.stop
  end
end

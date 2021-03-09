# frozen_string_literal: true

require "stimpack/event_source"

RSpec.describe Stimpack::EventSource do
  subject(:service) { klass }

  let(:klass) do
    Class.new do
      include Stimpack::EventSource

      def self.to_s
        "Foo"
      end
    end
  end

  describe ".on" do
    it { expect { service.on(:foo) {} }.to change { klass.event_listeners["Foo.foo"].size }.by(1) }
  end

  describe "#emit" do
    let(:receiver) { spy }

    before do
      allow(receiver).to receive(:qux)

      service.on(:qux) { |d| receiver.baz(d) }

      service.new.emit(:qux, { quux: 1 })
    end

    it { expect(receiver).to have_received(:baz).with(Stimpack::EventSource::Event) }
  end
end

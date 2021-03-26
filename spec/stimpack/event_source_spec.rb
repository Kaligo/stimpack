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

  describe ".error_handler" do
    context "when no error handler has been configured" do
      it { expect(described_class.error_handler).to respond_to(:call) }
    end

    context "when an error handler has been configured" do
      let(:error_handler) { instance_double(Proc) }

      before do
        described_class.error_handler = error_handler
      end

      after do
        described_class.error_handler = nil
      end

      it { expect(described_class.error_handler).to eq(error_handler) }
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

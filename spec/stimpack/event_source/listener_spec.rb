# frozen_string_literal: true

require "stimpack/event_source"

RSpec.describe Stimpack::EventSource::Listener do
  subject(:listener) { described_class.new(raise_errors: raise_errors, &block) }

  let(:raise_errors) { false }

  describe "#call" do
    context "when no errors are raised" do
      let(:receiver) { spy }

      let(:block) do
        proc { receiver.foo }
      end

      before do
        allow(receiver).to receive(:foo)

        listener.()
      end

      it { expect(receiver).to have_received(:foo).once }
    end

    context "when errors are raised" do
      let(:block) do
        proc { raise StandardError }
      end

      context "when configured to raise errors" do
        let(:raise_errors) { true }

        it { expect { listener.() }.to raise_error(StandardError) }
      end

      context "when configured to not raise errors" do
        let(:raise_errors) { false }

        it { expect { listener.() }.not_to raise_error }
      end
    end
  end
end

# frozen_string_literal: true

require "stimpack/event_source"

RSpec.describe Stimpack::EventSource::Event do
  subject(:event) { described_class.new(name, data) }

  describe "#name" do
    let(:name) { "foo.bar.baz" }
    let(:data) {}

    it { expect(event.name).to eq("foo.bar.baz") }
  end

  describe "#method_missing" do
    let(:name) { "foo.bar.baz" }

    context "when field is found in data" do
      let(:data) do
        {
          foo: "bar"
        }
      end

      it { expect(event.foo).to eq("bar") }
    end

    context "when field is not found in data" do
      let(:data) do
        {}
      end

      it { expect { event.foo }.to raise_error(NoMethodError) }
    end
  end
end

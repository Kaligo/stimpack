# frozen_string_literal: true

require "stimpack/result_monad"

RSpec.describe Stimpack::ResultMonad do
  subject(:service) { klass }

  let(:super_klass) do
    Class.new do
      include Stimpack::ResultMonad
    end
  end

  let(:klass) do
    Class.new(super_klass) do
      def success_result(**options)
        success(**options)
      end

      def error_result(errors:)
        error(errors: errors)
      end

      def accumulator; end

      def self.to_s
        "Foo"
      end
    end
  end

  describe ".result" do
    context "when declaring a blank result" do
      it { expect { service.result }.to raise_error(ArgumentError) }
    end

    context "when declaring a result key" do
      it { expect { service.result(:foo) }.not_to raise_error }
    end
  end

  describe ".blank_result" do
    context "when declaring a blank result" do
      it { expect { service.blank_result }.not_to raise_error }
    end

    context "when declaring a result key" do
      it { expect { service.blank_result(:foo) }.to raise_error(ArgumentError) }
    end
  end

  describe ".blank_result?" do
    context "when a blank result is declared" do
      before { service.blank_result }

      it { expect(service).to be_blank_result }
    end

    context "when a result key is declared" do
      before { service.result(:foo) }

      it { expect(service).not_to be_blank_result }
    end
  end

  describe ".result_key" do
    context "when a result key is declared" do
      before { service.result(:foo) }

      it { expect(service.result_key).to eq(:foo) }
    end

    context "when a blank result is declared" do
      before { service.blank_result }

      it { expect(service.result_key).to eq(nil) }
    end
  end

  describe ".result_struct" do
    context "when a result key is declared" do
      before { service.result(:foo) }

      it { expect(service.result_struct.members).to contain_exactly(:foo, :errors, :klass) }
    end

    context "when a blank result is declared" do
      before { service.blank_result }

      it { expect(service.result_struct.members).to contain_exactly(:errors, :klass) }
    end
  end

  describe ".before_success" do
    let(:instance) { service.new }
    let(:accumulator) { spy }

    before do
      allow(instance).to receive(:accumulator).and_return(accumulator)

      allow(accumulator).to receive(:callback)
      allow(accumulator).to receive(:parent_callback)

      service.blank_result
      service.before_success { accumulator.callback }

      super_klass.before_success { accumulator.parent_callback }

      instance.success_result
    end

    it "runs the callbacks up the class hierarchy" do
      expect(accumulator).to have_received(:callback).ordered
      expect(accumulator).to have_received(:parent_callback).ordered
    end
  end

  describe ".before_error" do
    let(:instance) { service.new }
    let(:accumulator) { spy }

    before do
      allow(instance).to receive(:accumulator).and_return(accumulator)

      allow(accumulator).to receive(:callback)
      allow(accumulator).to receive(:parent_callback)

      service.blank_result
      service.before_error { accumulator.callback }

      super_klass.before_error { accumulator.parent_callback }

      instance.error_result(errors: ["foo"])
    end

    it "runs the callbacks up the class hierarchy" do
      expect(accumulator).to have_received(:callback).ordered
      expect(accumulator).to have_received(:parent_callback).ordered
    end
  end

  describe ".after_success" do
    let(:instance) { service.new }
    let(:accumulator) { spy }

    before do
      allow(instance).to receive(:accumulator).and_return(accumulator)

      allow(accumulator).to receive(:callback)
      allow(accumulator).to receive(:parent_callback)

      service.blank_result
      service.after_success { accumulator.callback }

      super_klass.after_success { accumulator.parent_callback }

      instance.success_result
    end

    it "runs the callbacks up the class hierarchy" do
      expect(accumulator).to have_received(:callback).ordered
      expect(accumulator).to have_received(:parent_callback).ordered
    end
  end

  describe ".after_error" do
    let(:instance) { service.new }
    let(:accumulator) { spy }

    before do
      allow(instance).to receive(:accumulator).and_return(accumulator)

      allow(accumulator).to receive(:callback)
      allow(accumulator).to receive(:parent_callback)

      service.blank_result
      service.after_error { accumulator.callback }

      super_klass.after_error { accumulator.parent_callback }

      instance.error_result(errors: ["foo"])
    end

    it "runs the callbacks up the class hierarchy" do
      expect(accumulator).to have_received(:callback).ordered
      expect(accumulator).to have_received(:parent_callback).ordered
    end
  end

  describe "#success" do
    before { service.result(:foo) }

    let(:instance) { service.new }

    context "when arguments match declared result" do
      it { expect(instance.success_result(foo: "bar")).to be_successful }
      it { expect(instance.success_result(foo: "bar").foo).to eq("bar") }
    end

    context "when arguments don't match declared result" do
      it { expect { instance.success_result(bar: "baz") }.to raise_error(described_class::IncompatibleResultError) }
    end
  end

  describe "#error" do
    before { service.result(:foo) }

    let(:instance) { service.new }

    it { expect(instance.error_result(errors: ["foo"])).to be_failed }
    it { expect(instance.error_result(errors: ["foo"]).errors).to eq(["foo"]) }
  end
end

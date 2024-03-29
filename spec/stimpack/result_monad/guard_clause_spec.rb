# frozen_string_literal: true

require "stimpack/result_monad"

RSpec.describe Stimpack::ResultMonad::GuardClause do
  subject(:service) { klass }

  let(:instance) { service.new(private_error: private_error) }
  let(:private_error) { false }

  let(:klass) do
    Class.new do
      include Stimpack::ResultMonad

      result :foo

      def initialize(private_error: false)
        @private_error = private_error
      end

      attr_reader :private_error

      def success_result(**options)
        success(**options)
      end

      def error_result(errors:)
        error(errors: errors)
      end

      def self.to_s
        "Foo"
      end

      def call
        guard :foo

        bar_result = guard { bar }
        baz_result = guard { baz }

        guard { qux } if private_error

        success(foo: bar_result + baz_result)
      rescue StandardError
        error(errors: "Something went wrong, but not a guard fail.")
      end

      private

      def foo
        # Stubbed in test cases.
      end

      def bar
        # Stubbed in test cases.
      end

      def baz
        pass("Baz")
      end

      def qux
        error(errors: ["Same class error"])
      end
    end
  end

  let(:inner_service_error) do
    double(
      Stimpack::ResultMonad::Result,
      failed?: true,
      klass: "Foo",
      errors: ["Inner error"]
    )
  end

  let(:inner_service_success) do
    double(
      Stimpack::ResultMonad::Result,
      failed?: false,
      klass: "Foo",
      unwrap!: "Foo",
      errors: nil
    )
  end

  describe "#guard" do
    context "when using a label" do
      it { expect { instance.guard(:foo) }.not_to raise_error(ArgumentError) }
    end

    context "when using a block" do
      it { expect { instance.guard { :foo } }.not_to raise_error(ArgumentError) }
    end

    context "when using both a label and a block" do
      it { expect { instance.guard(:foo) { :foo } }.not_to raise_error(ArgumentError) }
    end

    context "when using no arguments" do
      it { expect { instance.guard }.to raise_error(ArgumentError) }
    end
  end

  describe ".call" do
    context "when all guards pass" do
      before do
        allow(instance).to receive(:foo).and_return(inner_service_success)
        allow(instance).to receive(:bar).and_return(inner_service_success)
      end

      it { expect(instance.()).to be_successful }
      it { expect(instance.().foo).to eq("FooBaz") }
    end

    context "when a guard fails" do
      context "when guard is invoked using a label" do
        before do
          allow(instance).to receive(:foo).and_return(inner_service_error)
          allow(instance).to receive(:bar).and_return(inner_service_success)
        end

        it { expect(instance.()).to be_failed }
        it { expect(instance.().errors).to eq(["Inner error"]) }
      end

      context "when guard is invoked using a block" do
        before do
          allow(instance).to receive(:foo).and_return(inner_service_success)
          allow(instance).to receive(:bar).and_return(inner_service_error)
        end

        it { expect(instance.()).to be_failed }
        it { expect(instance.().errors).to eq(["Inner error"]) }
      end
    end
  end

  describe ".before_error" do
    context "when inner service fails" do
      before do
        allow(instance).to receive(:inspect)
        allow(instance).to receive(:foo).and_return(inner_service_error)

        service.before_error { inspect }

        instance.()
      end

      it { expect(instance).to have_received(:inspect).once }
    end

    context "when passing an error from an instance method" do
      let(:private_error) { true }

      before do
        allow(instance).to receive(:inspect)
        allow(instance).to receive(:foo).and_return(inner_service_success)
        allow(instance).to receive(:bar).and_return(inner_service_success)

        service.before_error { inspect }

        instance.()
      end

      it { expect(instance).to have_received(:inspect).once }
    end
  end
end

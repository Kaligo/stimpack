# frozen_string_literal: true

require "stimpack/result_monad"

RSpec.describe Stimpack::ResultMonad::GuardClause do
  subject(:service) { klass }

  let(:instance) { service.new }

  let(:klass) do
    Class.new do
      include Stimpack::ResultMonad

      result :foo

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
        guard { bar }

        success(foo: "bar")
      end

      private

      def foo
        # Stubbed in test cases.
      end

      def bar
        # Stubbed in test cases.
      end
    end
  end

  let(:inner_service_error) do
    double(
      Stimpack::ResultMonad::Result,
      failed?: true,
      errors: ["Inner error"]
    )
  end

  let(:inner_service_success) do
    double(
      Stimpack::ResultMonad::Result,
      failed?: false,
      errors: []
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
    before do
      allow(instance).to receive(:inspect)
      allow(instance).to receive(:foo).and_return(inner_service_error)

      service.before_error { inspect }

      instance.()
    end

    it { expect(instance).to have_received(:inspect).once }
  end
end

# frozen_string_literal: true

require "stimpack/functional_object"

RSpec.describe Stimpack::FunctionalObject do
  subject(:service) { klass }

  describe ".call" do
    context "when service does not implement #call" do
      let(:klass) do
        Class.new do
          include Stimpack::FunctionalObject
        end
      end

      it { expect { klass.() }.to raise_error(NotImplementedError) }
    end

    context "when service implements #call" do
      let(:klass) do
        Class.new do
          include Stimpack::FunctionalObject

          def initialize(foo, bar:)
            @foo = foo
            @bar = bar
          end

          attr_reader :foo, :bar

          def call
            [foo, bar]
          end
        end
      end

      it "delegates arguments, options, and block" do
        expect(klass.("foo", bar: "bar") { "baz" }).to eq(%w[foo bar])
      end

      it "yields the return value to the block if given" do
        expect { |block| klass.("foo", bar: "bar", &block) }.to yield_with_args(%w[foo bar])
      end
    end
  end
end

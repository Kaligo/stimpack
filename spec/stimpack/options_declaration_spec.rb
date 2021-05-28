# frozen_string_literal: true

require "stimpack/options_declaration"

RSpec.describe Stimpack::OptionsDeclaration do
  subject(:service) { klass }

  let(:klass) do
    Class.new do
      include Stimpack::OptionsDeclaration

      option :foo
      option :bar, required: false
      option :baz, private_reader: false
      option :qux, default: "Foo"
      option :quuz, default: nil
      option :quux, default: -> { "Bar" }
      option :corge, transform: ->(value) { value.upcase }
      option :grault, default: "bar", transform: ->(value) { value.upcase }
      option :garply, default: "baz", transform: :upcase
    end
  end

  describe ".option" do
    it { expect(service.options_configuration.size).to eq(9) }
    it { expect(service.options_configuration.values).to all(be_a(described_class::Option)) }

    describe "private_reader (option)" do
      let(:public_instance_methods) { service.public_instance_methods(false) }
      let(:private_instance_methods) { service.private_instance_methods(false) }

      it { expect(public_instance_methods).to contain_exactly(:baz) }
      it { expect(private_instance_methods).to contain_exactly(:foo, :bar, :qux, :quux, :quuz, :corge, :grault, :garply) } # rubocop:disable Layout/LineLength
    end
  end

  describe ".options" do
    it { expect(service.options).to contain_exactly(:foo, :bar, :baz, :qux, :quux, :quuz, :corge, :grault, :garply) }
  end

  describe ".required_options" do
    it { expect(service.required_options).to contain_exactly(:foo, :baz, :corge) }
  end

  describe ".optional_options" do
    it { expect(service.optional_options).to contain_exactly(:bar, :qux, :quux, :quuz, :grault, :garply) }
  end

  describe ".default_options" do
    it { expect(service.default_options).to contain_exactly(:qux, :quux, :quuz, :grault, :garply) }
  end

  describe "#initialize" do
    context "when not passing required options" do
      it { expect { service.new }.to raise_error(ArgumentError) }
    end

    context "when omitting only optional options" do
      let(:options) do
        {
          foo: 1,
          baz: 2,
          corge: "foo"
        }
      end

      it { expect { service.new(**options) }.not_to raise_error }
    end

    describe "argument assignment" do
      let(:instance) { service.new(**options) }

      let(:options) do
        {
          foo: 1,
          baz: 2,
          corge: "foo"
        }
      end

      context "when option is assigned explicitly" do
        it { expect(instance.send(:foo)).to eq(1) }
        it { expect(instance.send(:baz)).to eq(2) }
      end

      context "when option with default is assigned explicitly" do
        before { options.merge!(qux: 3) }

        it { expect(instance.send(:qux)).to eq(3) }
      end

      context "when optional option is assigned through omission" do
        it { expect(instance.send(:bar)).to eq(nil) }
      end

      context "when default option is assigned by omission" do
        it { expect(instance.send(:qux)).to eq("Foo") }
        it { expect(instance.send(:quux)).to eq("Bar") }
        it { expect(instance.send(:quuz)).to eq(nil) }
      end

      context "when transform is applied to user input" do
        it { expect(instance.send(:corge)).to eq("FOO") }
      end

      context "when transform is applied to default" do
        it { expect(instance.send(:grault)).to eq("BAR") }
      end

      context "when using a method name for transform" do
        it { expect(instance.send(:garply)).to eq("BAZ") }
      end
    end
  end

  describe "#initialize (multiple-layer inheritance)" do
    let(:sub_klass) do
      Class.new(klass) do
        # Override option :foo and add 2 more options.
        #
        option :lorem, :ipsum, :foo, private_reader: false

        attr_accessor :hello, :world, :qux

        def initialize(hello, world:, **options)
          super(**options)
          @hello = hello
          @world = world
        end
      end
    end

    let(:instance) do
      sub_klass.new("hello", world: "world", foo: 1, baz: 2, corge: "foo", lorem: 3, ipsum: 4) do |instance|
        instance.qux = instance.lorem + instance.ipsum
      end
    end

    it { expect(instance.hello).to eq("hello") }
    it { expect(instance.world).to eq("world") }
    it { expect(instance.foo).to eq(1) }
    it { expect(instance.baz).to eq(2) }
    it { expect(instance.lorem).to eq(3) }
    it { expect(instance.ipsum).to eq(4) }
    it { expect(instance.qux).to eq(7) }
  end
end

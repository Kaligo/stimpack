# frozen_string_literal: true

require "stimpack/result_monad"

RSpec.describe Stimpack::ResultMonad::Result do
  subject(:service) { klass }

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
    end
  end

  let(:instance) { service.new }

  describe "#inspect" do
    context "when result is successful" do
      it { expect(instance.success_result(foo: "bar").inspect).to eq("<Foo:successful foo : \"bar\">") }
    end

    context "when result is failed" do
      it { expect(instance.error_result(errors: "Oops!").inspect).to eq("<Foo:failed errors : \"Oops!\">") }
    end
  end
end

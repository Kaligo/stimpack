# frozen_string_literal: true

module Stimpack
  module EventSource
    # A thin wrapper around a block with the option to rescue errors and
    # leave them unhandled. This lets us safely execute registered event
    # listeners without worrying that they will raise an error and
    # unexpectedly terminate the program.
    #
    class Listener
      def initialize(raise_errors:, &block)
        @block = block
        @raise_errors = raise_errors
      end

      def call(...)
        block.(...)
      rescue StandardError => e
        raise e if raise_errors
      end

      private

      attr_reader :raise_errors, :block
    end
  end
end

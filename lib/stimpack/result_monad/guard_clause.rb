# frozen_string_literal: true

module Stimpack
  module ResultMonad
    PassResult = Result.new(:klass, :errors, :_value, keyword_init: true)

    # This module adds a `#guard` method, which can be used inside a `#call`
    # to declare a step which, if it fails, breaks the flow of the method and
    # propagates the error result.
    #
    # Example:
    #
    #   def call
    #     guard :price_check
    #
    #     ...
    #   end
    #
    # In the above example, if the price check fails, the wrapping service
    # will halt and return an error result. This replaces use of `return`, and
    # has the benefit of invoking all related callbacks on *both* services if
    # the guard fails.
    #
    module GuardClause
      # This module prepends a wrapper `#call` method which "catches" errors
      # returned from the guarded service, and propagates the error result.
      #
      module GuardCatcher
        def call
          super
        rescue GuardFailed => e
          # Avoid running the error callback in the case where it was already
          # called by using `#error` in an instance method that is guarded
          # against in the `#call` method.
          #
          run_callback(:error) unless e.result.klass == self.class

          e.result
        end
      end

      # This error is used to break out of the current execution flow when a
      # guard fails. It carries the error result with it, and passes it to the
      # caller which can then work with it.
      #
      class GuardFailed < Exception # rubocop:disable Lint/InheritException
        # rubocop:disable Lint/MissingSuper
        def initialize(result)
          @result = result
        end
        # rubocop:enable Lint/MissingSuper

        attr_reader :result
      end

      # The guard declaration takes either a label, a block, or both (in which
      # case the block takes precedence.) A label is interpreted as an instance
      # method of the service.
      #
      def guard(label = nil, &block)
        raise ArgumentError, "Guard needs either a label or a block." if label.nil? && !block_given?

        result = block_given? ? instance_eval(&block) : send(label)

        raise GuardFailed, result if result.failed?

        result.unwrap!
      end

      # A standardized result object which can be used to pass guards.
      #
      def pass(value = nil)
        PassResult.new(klass: self.class, errors: nil, _value: value)
      end

      def self.included(klass)
        klass.prepend(GuardCatcher)
      end
    end
  end
end

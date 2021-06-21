# frozen_string_literal: true

module Stimpack
  module OptionsDeclaration
    # A small value object representing an option and its configuration.
    #
    class Option
      # Used in lieu of `nil` to differentiate between an option that was
      # omitted and one that was explicitly set to `nil`.
      #
      MISSING_VALUE = "__missing__"
      NO_TRANSFORM = "__noop__"

      def initialize(name, required:, default:, transform:)
        @name = name
        @default = default
        @required = required
        @transform = transform
      end

      attr_reader :name

      def default_value
        return nil unless default?

        default.respond_to?(:call) ? default.() : default
      end

      def transformed_value(value)
        transform? && value ? transform.to_proc.(value) : value
      end

      def required?
        required && !default?
      end

      def optional?
        !required?
      end

      def default?
        default != MISSING_VALUE
      end

      def transform?
        transform != NO_TRANSFORM
      end

      private

      attr_reader :default, :required, :transform
    end
  end
end

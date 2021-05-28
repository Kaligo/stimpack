# frozen_string_literal: true

# TODO: Remove dependency on ActiveSupport.
#
require "active_support/core_ext/class/attribute"

require_relative "./options_declaration/initializer"
require_relative "./options_declaration/option"

module Stimpack
  # This mixin is used to augment classes with a DSL for declaring keyword
  # arguments. It is used to cut down on noise for a common initialization
  # pattern, which goes:
  #
  #   1. Declare parameters in `#initialize`.
  #   2. Assign attributes to instance variables.
  #   3. Add private reader methods.
  #
  # Example:
  #
  #   # Before
  #
  #   class AccruePoints
  #     def initialize(user:, amount:)
  #       @user = user
  #       @amount = amount
  #     end
  #
  #     private
  #
  #     attr_reader :user, :amount
  #   end
  #
  #   # After
  #
  #   class AccruePoints
  #     option :user
  #     option :amount
  #   end
  #
  module OptionsDeclaration
    module ClassMethods
      def self.extended(klass)
        klass.class_eval do
          # TODO: Remove dependency on ActiveSupport.
          #
          class_attribute :options_configuration, instance_accessor: false, default: {}
        end
      end

      # Declare a keyword argument for this class.
      #
      # Example:
      #
      #   class AccruePoints
      #     option :user
      #   end
      #
      # rubocop:disable Metrics/MethodLength
      def option(
        *identifiers,
        required: true,
        default: Option::MISSING_VALUE,
        transform: Option::NO_TRANSFORM,
        private_reader: true
      )
        self.options_configuration = options_configuration.merge(
          identifiers.map do |identifier|
            [
              identifier.to_sym,
              Option.new(
                identifier.to_sym,
                required: required,
                default: default,
                transform: transform
              )
            ]
          end.to_h
        )

        identifiers.each do |identifier|
          class_eval do
            attr_reader identifier.to_sym

            private identifier.to_sym if private_reader
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      def options
        options_configuration.keys
      end

      def required_options
        options_configuration.select { |_, option| option.required? }.keys
      end

      def optional_options
        options_configuration.select { |_, option| option.optional? }.keys
      end

      def default_options
        options_configuration.select { |_, option| option.default? }.keys
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.include(Initializer)
    end
  end
end

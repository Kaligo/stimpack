# frozen_string_literal: true

# TODO: Remove dependency on ActiveSupport.
#
require "active_support/core_ext/class/attribute"

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
      def option(*identifiers, required: true, default: nil, private_reader: true) # rubocop:disable Metrics/MethodLength
        self.options_configuration = options_configuration.merge(
          identifiers.map do |identifier|
            [
              identifier.to_sym,
              Option.new(
                identifier.to_sym,
                required: required,
                default: default
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

      def options
        options_configuration.keys
      end

      def required_options
        options_configuration.select { |_, option| option.required? }.keys
      end

      def optional_options
        options_configuration.select { |_, option| option.optional? }.keys
      end
    end

    # Injects an initializer that assigns options and proxies the call to any
    # custom initializer _without_ the declared options included in the call.
    #
    module OptionsInitializer
      def initialize(*_args, **options)
        assigner = OptionsAssigner.new(self, options)
        assigner.assign_options!
        yield self if block_given?
      end

      class OptionsAssigner
        def initialize(service, options)
          @service = service
          @options = options
        end

        def assign_options!
          check_for_missing_options!

          service.class.options_configuration.each_value { |o| assign_option(o) }
        end

        private

        attr_reader :service, :options

        def check_for_missing_options!
          raise(ArgumentError, <<~ERROR) unless missing_options.empty?
            Missing required options: #{missing_options.join(', ')}
          ERROR
        end

        def assign_option(option)
          assigned_value = options[option.name]

          service.instance_variable_set(
            "@#{option.name}",
            assigned_value.nil? ? option.default_value : assigned_value
          )
        end

        def missing_options
          required_options - options.keys
        end

        def required_options
          service.class.required_options
        end
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.include(OptionsInitializer)
    end

    class Option
      def initialize(name, required:, default:)
        @name = name
        @default = default
        @required = required
      end

      attr_reader :name, :default, :required

      def default_value
        default.respond_to?(:call) ? default.() : default
      end

      def required?
        required && default.nil?
      end

      def optional?
        !required?
      end
    end
  end
end

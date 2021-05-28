# frozen_string_literal: true

module Stimpack
  module OptionsDeclaration
    # An injectable initializer that assigns options on object creation and
    # raises an error when required options are missing.
    #
    module Initializer
      def initialize(*_, **options)
        OptionsAssigner.new(self, options).assign_options!

        yield self if block_given?
      end

      # This inner class minimizes pollution of the consumer class by
      # encapsulating the methods needed for initialization.
      #
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

          value = assigned_value.nil? ? option.default_value : assigned_value

          service.instance_variable_set(
            "@#{option.name}",
            option.transformed_value(value)
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
  end
end

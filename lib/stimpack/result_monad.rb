# frozen_string_literal: true

module Stimpack
  module ResultMonad
    class IncompatibleResultError < ArgumentError; end

    module ClassMethods
      # Used to declare the structure of the result object in the case of a
      # successful invocation, e.g.:
      #
      #   class StoreMembership
      #     result :membership
      #   end
      #
      def result(attribute = nil)
        raise ArgumentError, "Use `#blank_result` to declare an empty service result" if attribute.nil?

        @result_key = attribute

        build_result_struct(attribute)
      end

      # Used to declare a result object which does not carry any data, e.g.:
      #
      #   class DeliverEmail
      #     blank_result
      #   end
      #
      def blank_result(attribute = nil)
        raise ArgumentError, "Use `#result` to declare a non-empty service result" unless attribute.nil?

        build_result_struct
      end

      def blank_result?
        result_key.nil?
      end

      instance_eval do
        attr_reader :result_key
        attr_reader :result_struct
      end

      protected

      def build_result_struct(attribute = nil)
        attributes = [:errors, attribute].compact

        @result_struct = Struct.new(*attributes, keyword_init: true) do
          def successful?
            errors.nil?
          end

          def failed?
            !successful?
          end
        end.freeze
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    private

    # To be called from within an object when its invocation is successful, e.g.:
    #
    #   if membership.save
    #     success(membership: membership)
    #   end
    #
    # The arguments are defined by the class' `result` declaration. (See above.)
    #
    def success(**result_attributes)
      raise incompatible_result_error(result_attributes.keys) unless compatible_result?(**result_attributes)

      self.class.result_struct.new(**result_attributes)
    end

    # To be called from within an object when its invocation fails.
    #
    def error(errors:)
      self.class.result_struct.new(errors: errors)
    end
    alias_method :error_with, :error

    # Check that the key passed to `#success` is the key that is declared for this
    # service class. (Or that nothing is passed in the case the service class has
    # declared a blank result.)
    #
    def compatible_result?(**result_attributes)
      return true if result_attributes.nil? || result_attributes.empty? && self.class.blank_result?

      result_attributes.keys == [self.class.result_key]
    end

    def incompatible_result_error(actual_attributes)
      IncompatibleResultError.new(<<~MESSAGE)
        Expected result to be constructed with:

          #{self.class.blank_result? ? 'no attributes' : self.class.result_key}

        But it was constructed with:

          #{actual_attributes.empty? ? 'no attributes' : actual_attributes}
      MESSAGE
    end
  end
end
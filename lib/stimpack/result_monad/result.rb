# frozen_string_literal: true

module Stimpack
  module ResultMonad
    class Result < Struct
      class UnwrapError < StandardError; end

      def successful?
        errors.nil?
      end

      def failed?
        !successful?
      end

      def unwrap!
        raise UnwrapError, "Can not unwrap a failed result." if failed?
        return if klass.blank_result?

        public_send(result_key)
      end

      def inspect
        if successful?
          "<#{klass}:successful #{result_key} : #{self[result_key].inspect}>"
        else
          "<#{klass}:failed errors : #{errors.inspect}>"
        end
      end

      private

      def result_key
        (members - %i[klass errors]).first
      end
    end
  end
end

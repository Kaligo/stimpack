# frozen_string_literal: true

module Stimpack
  # This mixin adds a `#call` class method which instantiates an object and
  # proxies arguments to the `#call` method. This allows for shorthand
  # invocation, e.g.:
  #
  #   AccruePoints.(user: user, amount: amount)
  #
  # which shortens code and aids when stubbing results in tests.
  #
  module FunctionalObject
    module ClassMethods
      def call(*arguments, **options)
        result = new(*arguments, **options).()

        yield result if block_given?

        result
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    # This is the main entry point to be implemented by each concrete class.
    #
    def call
      raise NotImplementedError
    end
  end
end

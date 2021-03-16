# frozen_string_literal: true

module Stimpack
  module EventSource
    # A thin wrapper around an event that encapsulates the event name and
    # data payload. Acts similar to an OpenStruct to simplify access to the
    # event data and give better error messages when the data is missing.
    #
    # Example:
    #
    #   event = Event.new("foo", { bar: "Hello, world!" })
    #
    #   event.bar
    #   #=> "Hello world!"
    #
    class Event
      def initialize(name, data = {})
        @name = name
        @data = data
      end

      attr_reader :name, :data

      def respond_to_missing?(method)
        data.key?(method) || super
      end

      def method_missing(method, *arguments, &block)
        if data.key?(method)
          data[method]
        else
          super
        end
      end
    end
  end
end

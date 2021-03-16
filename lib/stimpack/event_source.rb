# frozen_string_literal: true

require_relative "./event_source/event"
require_relative "./event_source/listener"

module Stimpack
  # This mixin turns the class into an event subject with which observers can
  # register callbacks to be executed in response to certain events.
  #
  # Example:
  #
  #   class Checkout
  #     include EventSource
  #
  #     def call
  #       emit(:error, { message: "Oops!" })
  #     end
  #   end
  #
  #   Checkout.on(:error) { |event| Appsignal.report(event.message) }
  #
  module EventSource
    module ClassMethods
      # Callback registry that stores a mapping of callbacks for all concrete
      # service classes. The registry is a hash that lives in the base class,
      # where the keys are `class_name.event_name`, and the values are
      # instances of `Listener`.
      #
      def self.extended(klass)
        klass.class_eval do
          @event_listeners = Hash.new { |h, k| h[k] = [] }

          class << self
            attr_reader :event_listeners
          end
        end
      end

      def on(event_name, raise_errors: false, &block)
        listener = Listener.new(raise_errors: raise_errors, &block)

        event_listeners["#{self}.#{event_name}"] << listener
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    def emit(event_name, data)
      event_name = "#{self.class}.#{event_name}"

      event = Event.new(event_name, data)

      self.class.event_listeners[event_name].each { |l| l.(event) }
    end
  end
end

# frozen_string_literal: true

# TODO: Remove dependency on ActiveSupport.
#
require "active_support/core_ext/class/attribute"

module Stimpack
  module EventSource
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

    module ClassMethods
      def self.extended(klass)
        klass.class_eval do
          # TODO: Remove dependency on ActiveSupport.
          #
          class_attribute :event_listeners,
                          instance_accessor: false,
                          default: Hash.new { |h, k| h[k] = [] }
        end
      end

      def on(event_name, &block)
        event_listeners["#{self}.#{event_name}"] << block
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

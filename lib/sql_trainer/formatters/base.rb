# frozen_string_literal: true

# lib/sql_trainer/formatters/base.rb
module SqlTrainer
  module Formatters
    class Base
      include(Components::Colorizable)

      attr_reader(:data)

      def initialize(data)
        @data = data
      end

      def format
        raise(NotImplementedError, "#{self.class} must implement #format.")
      end

      private

      def section
        Components::Section
      end

      def table_builder
        Components::TableBuilder
      end

      def value_formatter
        Components::ValueFormatter
      end

      def empty_message(key)
        colorize(Settings.schema_message(key), :warning)
      end
    end
  end
end

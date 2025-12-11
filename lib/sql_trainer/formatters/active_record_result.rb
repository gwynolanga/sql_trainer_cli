# frozen_string_literal: true

# lib/sql_trainer/formatters/active_record_result.rb
require_relative("base")

module SqlTrainer
  module Formatters
    class ActiveRecordResult < Base
      def format
        case data[:type]
        when :activerecord then format_records
        when :value then format_value
        else format_other
        end
      end

      private

      def format_records
        return empty_message(:no_records) if data[:result].empty?

        records = data[:result]
        attributes = extract_attributes(records.first)

        return records.map(&:inspect).join("\n") if attributes.empty?

        [
          colorize("Results table:", :warning),
          build_records_table(records, attributes),
          build_footer,
          sql_info
        ].compact.join("\n")
      end

      def format_value
        [
          colorize("Result: ", :success) + value_formatter.format(data[:result]),
          colorize("Execution time: #{data[:execution_time]} ms", :muted)
        ].join("\n")
      end

      def format_other
        [
          colorize("Result: ", :success),
          data[:result].inspect,
          colorize("Execution time: #{data[:execution_time]} ms", :muted)
        ].join("\n")
      end

      def extract_attributes(record)
        record.respond_to?(:attributes) ? record.attributes.keys : []
      end

      def build_records_table(records, attributes)
        rows = records.map do |record|
          attributes.map { |attr| value_formatter.format(record.send(attr)) }
        end

        table_builder.build(columns: attributes, rows: rows)
      end

      def build_footer
        row_word = data[:count] == 1 ? Settings.footer_config[:row_singular] : Settings.footer_config[:row_plural]
        parts = [
          colorize("#{data[:count]} #{row_word}", :success),
          colorize("#{data[:execution_time]} ms", :muted)
        ]
        parts.join(Settings.footer_config[:separator])
      end

      def sql_info
        return nil unless data[:sql].present?
        colorize("SQL: #{data[:sql]}", :secondary)
      end
    end
  end
end

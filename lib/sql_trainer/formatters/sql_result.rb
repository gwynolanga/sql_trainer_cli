# frozen_string_literal: true

# lib/sql_trainer/formatters/sql_result.rb
require_relative("base")

module SqlTrainer
  module Formatters
    class SqlResult < Base
      def format
        return empty_message(:no_data) if data[:rows].empty?

        [
          colorize("Results table:", :warning),
          build_results_table,
          build_footer
        ].join("\n")
      end

      private

      def build_results_table
        table_builder.build(
          columns: data[:columns],
          rows: data[:rows].map { |row| row.map { |val| value_formatter.format(val) } }
        )
      end

      def build_footer
        row_word = data[:count] == 1 ? Settings.footer_config[:row_singular] : Settings.footer_config[:row_plural]
        parts = [
          colorize("#{data[:count]} #{row_word}", :success),
          colorize("#{data[:execution_time]} ms", :muted)
        ]
        parts.join(Settings.footer_config[:separator])
      end
    end
  end
end

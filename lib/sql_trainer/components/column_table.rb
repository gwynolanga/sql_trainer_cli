# frozen_string_literal: true

# lib/sql_trainer/components/column_table.rb
require_relative("detail_table")

module SqlTrainer
  module Components
    class ColumnTable < DetailTable
      private

      def headings
        ["Name", "Type", "SQL Type", "Null", "Default"]
      end

      def build_row(col)
        [
          col[:name],
          colorize(col[:type], :warning),
          col[:sql_type],
          format_boolean(col[:null]),
          format_default(col[:default])
        ]
      end

      def format_default(value)
        return colorize("NULL", :muted) unless value.present?

        colorize(value, :info)
      end
    end
  end
end

# frozen_string_literal: true

# lib/sql_trainer/components/index_table.rb
require_relative("detail_table")

module SqlTrainer
  module Components
    class IndexTable < DetailTable
      private

      def headings
        %w[Name Columns Unique Type]
      end

      def build_row(idx)
        [
          idx[:name],
          colorize(idx[:columns].join(", "), :warning),
          format_boolean(idx[:unique]),
          idx[:type] || idx[:using] || colorize("N/A", :secondary)
        ]
      end
    end
  end
end

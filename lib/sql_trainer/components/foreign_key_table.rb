# frozen_string_literal: true

# lib/sql_trainer/components/foreign_key_table.rb
require_relative("detail_table")

module SqlTrainer
  module Components
    class ForeignKeyTable < DetailTable
      private

      def headings
        ["Name", "Column", "Link to", "On delete"]
      end

      def build_row(fk)
        [
          fk[:name] || colorize("N/A", :secondary),
          colorize(fk[:column], :warning),
          colorize("#{fk[:to_table]}.#{fk[:primary_key]}", :success),
          format_on_delete(fk[:on_delete])
        ]
      end

      def format_on_delete(action)
        mappings = {
          cascade: ["CASCADE", :info],
          nullify: ["NULLIFY", :muted],
          restrict: ["RESTRICT", :error]
        }

        text, color = mappings[action] || ["N/A", :secondary]
        colorize(text, color)
      end
    end
  end
end

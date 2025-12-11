# frozen_string_literal: true

# lib/sql_trainer/formatters/explain_plan.rb
require_relative("base")

module SqlTrainer
  module Formatters
    class ExplainPlan < Base
      def format
        return empty_message(:no_explain) if data[:rows].empty?

        [
          colorize("SQL query execution plan:", :warning),
          build_plan_table
        ].join("\n")
      end

      private

      def build_plan_table
        table_builder.build(
          columns: data[:columns],
          rows: data[:rows],
          color: :secondary
        )
      end
    end
  end
end

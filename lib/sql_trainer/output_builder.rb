# frozen_string_literal: true

# lib/sql_trainer/output_builder.rb
module SqlTrainer
  class OutputBuilder
    class << self
      def build(type, data)
        formatter = formatter_for(type)
        formatter.new(data).format
      end

      private

      def formatter_for(type)
        {
          sql_result: Formatters::SqlResult,
          ar_result: Formatters::ActiveRecordResult,
          explain: Formatters::ExplainPlan,
          connection: Formatters::Connection,
          tables_list: Formatters::TableList,
          table_info: Formatters::TableInfo,
          relationships: Formatters::Relationships
        }.fetch(type) { raise(ArgumentError, "Unknown formatter type: '#{type}'.") }
      end
    end
  end
end

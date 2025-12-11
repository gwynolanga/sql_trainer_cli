# frozen_string_literal: true

# lib/sql_trainer/query/executor.rb
module SqlTrainer
  module Query
    class Executor
      def initialize(database_manager)
        @database_manager = database_manager
      end

      def execute_sql(query)
        Validator.validate_sql!(query)
        result = measure_execution { connection.exec_query(query) }
        format_sql_result(result[:data], result[:time])
      rescue ActiveRecord::StatementInvalid => e
        raise(QueryExecutionError, "SQL execution —> #{e.message}")
      end

      def execute_activerecord(code)
        Validator.validate_activerecord!(code)
        result = measure_execution { eval(code, binding, "(activerecord query)", 1) }
        format_ar_result(result[:data], result[:time])
      rescue ActiveRecord::StatementInvalid => e
        raise(QueryExecutionError, "ActiveRecord execution —> #{e.message}")
      rescue NameError => e
        raise(QueryExecutionError, "Unknown model or method name —> #{e.message}")
      rescue SyntaxError => e
        raise(QueryExecutionError, "Syntax error —> #{e.message}")
      rescue StandardError => e
        raise(QueryExecutionError, "Unexpected error —> #{e.message}")
      end

      def explain_sql(query)
        Validator.validate_sql!(query)
        result = execute_explain_query(query)
        format_explain_result(result)
      rescue ActiveRecord::StatementInvalid => e
        raise(QueryExecutionError, "Error getting SQL execution plan —> #{e.message}")
      end

      private

      def connection
        @database_manager.connection
      end

      def measure_execution
        start_time = Time.now
        data = yield
        execution_time = ((Time.now - start_time) * 1000).round(2)
        { data: data, time: execution_time }
      end

      def execute_explain_query(query)
        connection.exec_query(explain_sql_for_adapter(query))
      end

      def explain_sql_for_adapter(query)
        @database_manager.adapter == "sqlite3" ? "EXPLAIN QUERY PLAN #{query}" : "EXPLAIN ANALYZE #{query}"
      end

      def format_sql_result(result, execution_time)
        {
          type: :sql,
          columns: result.columns,
          rows: result.rows,
          count: result.rows.size,
          execution_time: execution_time
        }
      end

      def format_ar_result(result, execution_time)
        case result
        when ActiveRecord::Relation then format_relation(result, execution_time)
        when Array then format_collection(result, execution_time)
        when ActiveRecord::Base then format_collection([result], execution_time)
        when Numeric, String, TrueClass, FalseClass, NilClass then format_simple_value(result, execution_time)
        else format_unknown_result(result, execution_time)
        end
      end

      def format_relation(result, execution_time)
        records = result.to_a
        {
          type: :activerecord,
          result: records,
          count: records.size,
          execution_time: execution_time,
          sql: result.to_sql
        }
      end

      def format_collection(result, execution_time)
        {
          type: :activerecord,
          result: result,
          count: result.size,
          execution_time: execution_time
        }
      end

      def format_simple_value(result, execution_time)
        {
          type: :value,
          result: result,
          execution_time: execution_time
        }
      end

      def format_unknown_result(result, execution_time)
        {
          type: :other,
          result: result,
          execution_time: execution_time
        }
      end

      def format_explain_result(result)
        {
          type: :explain,
          columns: result.columns,
          rows: result.rows
        }
      end
    end
  end
end

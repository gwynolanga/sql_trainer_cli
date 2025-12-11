# frozen_string_literal: true

# lib/sql_trainer/formatters/table_list.rb
require_relative("base")

module SqlTrainer
  module Formatters
    class TableList < Base
      def format
        return empty_message(:no_tables) if data.empty?

        section.build("List of available tables") do
          data.each_with_index.map do |table, index|
            colorize("#{(index + 1).to_s.rjust(3)}. #{table}", :success)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

# lib/sql_trainer/formatters/table_info.rb
require_relative("base")

module SqlTrainer
  module Formatters
    class TableInfo < Base
      def format
        section.build("Information about '#{data[:name]}' table") do
          [
            primary_key_info,
            columns_info,
            indexes_info,
            foreign_keys_info,
            row_count_info
          ].compact
        end
      end

      private

      def primary_key_info
        return nil unless data[:primary_key]

        info_line("Primary key", data[:primary_key]) + "\n"
      end

      def columns_info
        subsection("Columns", Components::ColumnTable.new(data[:columns]).build)
      end

      def indexes_info
        return nil if data[:indexes].empty?

        subsection("Indexes", Components::IndexTable.new(data[:indexes]).build)
      end

      def foreign_keys_info
        return nil if data[:foreign_keys].empty?

        subsection("Foreign keys", Components::ForeignKeyTable.new(data[:foreign_keys]).build)
      end

      def row_count_info
        return nil unless data[:row_count]

        info_line("Row count", data[:row_count])
      end

      def info_line(label, value)
        colorize("#{label}: ", :warning) + colorize(value, :success)
      end

      def subsection(title, content)
        colorize("#{title}:", :warning) + "\n" + content + "\n"
      end
    end
  end
end

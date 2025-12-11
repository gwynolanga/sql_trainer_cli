# frozen_string_literal: true

# lib/sql_trainer/components/detail_table.rb
module SqlTrainer
  module Components
    class DetailTable
      include(Colorizable)

      def initialize(data)
        @data = data
      end

      def build
        TableBuilder.build(columns: headings, rows: rows)
      end

      private

      def headings
        raise(NotImplementedError, "#{self.class} must implement #headings.")
      end

      def rows
        @data.map { |item| build_row(item) }
      end

      def build_row(_item)
        raise(NotImplementedError, "#{self.class} must implement #build_row.")
      end

      def format_boolean(value)
        text = value.present? ? "YES" : "NO"
        color = value.present? ? :success : :error
        colorize(text, color)
      end
    end
  end
end

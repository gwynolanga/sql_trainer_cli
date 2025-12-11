# frozen_string_literal: true

# lib/sql_trainer/components/table_builder.rb
module SqlTrainer
  module Components
    class TableBuilder
      class << self
        def build(columns:, rows:, color: nil)
          color ||= Settings.color(:primary)

          Terminal::Table.new do |t|
            t.headings = columns.map { |col| col.to_s.colorize(color) }
            rows.each { |row| t.add_row(row) }
            t.style = Settings.table_style
          end.to_s
        end
      end
    end
  end
end

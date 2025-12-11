# frozen_string_literal: true

# lib/sql_trainer/formatters/connection.rb
require_relative("base")

module SqlTrainer
  module Formatters
    class Connection < Base
      def format
        return empty_message(:no_connection) unless data.present?

        section.build("Current Connection") do
          [
            info_line("Domain", data[:domain]),
            info_line("Adapter", data[:adapter]),
            info_line("Database", data[:database])
          ]
        end
      end

      private

      def info_line(label, value)
        colorize("#{label}: ", :warning) + colorize(value, :success)
      end
    end
  end
end

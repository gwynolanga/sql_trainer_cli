# frozen_string_literal: true

# lib/sql_trainer/formatters/relationships.rb
require_relative("base")

module SqlTrainer
  module Formatters
    class Relationships < Base
      def format
        table_name = data[:table_name]
        relationships = data[:relationships]

        return no_model_message(table_name) if relationships.empty?

        section.build("Table relationships for '#{table_name}'") do
          output = [model_info(relationships[:model])]

          association_groups.each_with_index do |(type, associations), index|
            next unless associations.present?

            output.concat(format_association_group(type, associations))
            output << "" if index < association_groups.size - 1
          end

          output
        end
      end

      private

      def association_groups
        @association_groups ||= %i[has_many has_one belongs_to has_and_belongs_to_many]
                                  .map { |type| [type, data[:relationships][type]] }
                                  .select { |_, assocs| assocs.present? }
      end

      def model_info(model_name)
        colorize("Model: ", :warning) + colorize(model_name, :success) + "\n"
      end

      def format_association_group(type, associations)
        config = Settings.association_config(type)
        lines = [colorize(config[:label], config[:color])]

        associations.each do |assoc|
          line = "  - #{assoc[:name]} —> #{assoc[:class_name]}"
          line += " (FK: #{assoc[:foreign_key]})" if assoc[:foreign_key].present?
          lines << colorize(line, :success)
        end

        lines
      end

      def no_model_message(table_name)
        colorize(Settings.schema_message(:no_model) % table_name, :warning)
      end
    end
  end
end

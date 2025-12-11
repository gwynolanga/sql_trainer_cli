# frozen_string_literal: true

# lib/sql_trainer/settings.rb
module SqlTrainer
  class Settings
    class << self
      def load_file(settings_file)
        @settings ||= YamlLoader.load_file(settings_file)
      end

      def output_width = fetch("console.output_width", 100)
      def max_string_length = fetch("console.max_string_length", 150)
      def prompt_disconnected = fetch("console.prompts.disconnected", "sql-trainer> ")
      def prompt_connected = fetch("console.prompts.connected", "sql-trainer [%s]> ")
      def console_message(key) = fetch("console.messages.#{key}", "")
      def color(key) = fetch("console.colors.#{key}", :light_white).to_sym

      def table_style
        {
          border_x: fetch("formatter.table.border_x", "-"),
          border_i: fetch("formatter.table.border_i", "+"),
          padding_left: fetch("formatter.table.padding_left", 1),
          padding_right: fetch("formatter.table.padding_right", 1)
        }
      end

      def footer_config
        {
          row_singular: fetch("formatter.footer.row_singular", "row"),
          row_plural: fetch("formatter.footer.row_plural", "rows"),
          separator: fetch("formatter.footer.separator", " | ")
        }
      end

      def association_config(type)
        {
          label: fetch("formatter.associations.#{type}.label", ""),
          color: fetch("formatter.associations.#{type}.color", "light_magenta").to_sym
        }
      end

      def system_tables = fetch("schema.system_tables", %w[schema_migrations ar_internal_metadata])
      def schema_message(key) = fetch("schema.messages.#{key}", "")
      def forbidden_sql_commands = fetch("validator.forbidden_sql_commands", [])
      def forbidden_ar_methods = fetch("validator.forbidden_ar_methods", [])
      def validator_message(key) = fetch("validator.messages.#{key}", "")
      def system_databases = fetch("database.system_databases", {})
      def supported_adapters = fetch("database.supported_adapters", %w[postgresql mysql2 sqlite3])

      def fetch(key_path, default = nil)
        keys = key_path.to_s.split(".")
        value = keys.reduce(@settings) { |hash, key| hash.is_a?(Hash) ? hash[key] : nil }
        value.nil? ? default : value
      end
    end
  end
end

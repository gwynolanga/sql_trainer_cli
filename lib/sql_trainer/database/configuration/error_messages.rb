# frozen_string_literal: true

# lib/sql_trainer/database/configuration/error_messages.rb
module SqlTrainer
  module Database
    class Configuration
      module ErrorMessages
        class << self
          def file_not_found(path)
            "Database configuration file not found: #{path}. " \
              "Please create a database.yml file in the 'db/' directory."
          end

          def configuration_not_found(key)
            "Database configuration for key '#{key}' not found in database.yml file."
          end

          def invalid_key_format(key)
            supported_adapters = Settings.supported_adapters.map { |adapter| "'#{adapter}'" }.join(', ')
            "Invalid database configuration key format: '#{key}'. Expected format: '<domain>_<adapter>' " \
              "(e.g. 'learn_hub_postgresql'). Supported adapters: #{supported_adapters}."
          end

          def missing_adapter(key, expected_adapter)
            "Missing 'adapter' option for database configuration key '#{key}'. " \
              "Expected adapter: '#{expected_adapter}'. " \
              "The 'adapter' option is required and must specify the database type."
          end

          def adapter_mismatch(key, expected, actual)
            "Adapter mismatch for database configuration key '#{key}'. " \
              "Configuration key expects: '#{expected}'. But adapter option is: '#{actual}' " \
              "The adapter in the configuration key and in the configuration must match."
          end

          def missing_required_options(key, adapter, missing, required)
            missing_options = missing.map { |opt| "'#{opt}'" }.join(', ')
            required_options = required.map { |opt| "'#{opt}'" }.join(', ')
            "Missing required options for '#{key}' (#{adapter} adapter). " \
              "Missing options: #{missing_options}. Required options: #{required_options}."
          end

          def missing_database(key)
            "Missing 'database' option for database configuration key '#{key}'. " \
              "The 'database' option is required and must specify the database name or path."
          end

          def invalid_sql_database_name(key, expected, actual)
            "Invalid database name for '#{key}'. Expected: '#{expected}'. Got: '#{actual}'. " \
              "For PostgreSQL/MySQL, the database name should match the domain from the configuration key."
          end

          def invalid_sqlite_path(key, expected, actual)
            "Invalid SQLite database path for '#{key}'. " \
              "Expected pattern: `db/<domain>/<domain>.sqlite3`. " \
              "Recommended path: `#{expected}`. Got: `#{actual}`. " \
              "SQLite databases should be located in the domain-specific folder."
          end

          def unsupported_adapter(adapter)
            supported_adapters = Settings.supported_adapters.map { |adapter| "'#{adapter}'" }.join(', ')
            "Unsupported adapter '#{adapter}'. Supported adapters: #{supported_adapters}."
          end
        end
      end
    end
  end
end

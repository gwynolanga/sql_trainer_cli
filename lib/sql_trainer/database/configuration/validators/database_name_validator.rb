# frozen_string_literal: true

# lib/sql_trainer/database/configuration/validators/database_name_validator.rb
module SqlTrainer
  module Database
    class Configuration
      module Validators
        class DatabaseNameValidator
          attr_reader(:key, :config, :parsed_key, :adapter)

          def initialize(key, config, parsed_key, adapter)
            @key = key
            @config = config
            @parsed_key = parsed_key
            @adapter = adapter
          end

          def validate!
            case adapter
            when "postgresql", "mysql2" then validate_sql_database_name!(config["database"])
            when "sqlite3" then validate_sqlite_database_path!(config["database"])
            else raise(ConfigurationError, ErrorMessages.missing_database(key))
            end
          end

          private

          def validate_sql_database_name!(database)
            return if database == parsed_key.domain

            raise(ConfigurationError, ErrorMessages.invalid_sql_database_name(key, parsed_key.domain, database))
          end

          def validate_sqlite_database_path!(database)
            domain = parsed_key.domain
            pattern = %r{^db/#{Regexp.escape(domain)}/#{Regexp.escape(domain)}\.sqlite3$}
            return if database.match?(pattern)

            expected_path = "db/#{domain}/#{domain}.sqlite3"
            raise(ConfigurationError, ErrorMessages.invalid_sqlite_path(key, expected_path, database))
          end
        end
      end
    end
  end
end

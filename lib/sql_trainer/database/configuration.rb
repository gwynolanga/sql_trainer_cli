# frozen_string_literal: true

# lib/sql_trainer/database/configuration.rb
module SqlTrainer
  module Database
    class Configuration
      CONFIGURATION_KEY_PATTERN = %r{^(?<domain>\w+)_(?<adapter>postgresql|mysql2|sqlite3)$}
      REQUIRED_OPTIONS = {
        postgresql: %w[adapter database pool username password host port],
        mysql2: %w[adapter database pool username password host port],
        sqlite3: %w[adapter database pool timeout]
      }.freeze

      class << self
        def extract_domain(key)
          match = key.downcase.match(CONFIGURATION_KEY_PATTERN)
          match && match[:domain]
        end
      end

      def initialize(db_config_file: SqlTrainer.database_configuration_file)
        @configurations = YamlLoader.load_file(db_config_file) do |configurations|
          configurations.each { |key, config| Validator.new(key, config).validate! }
        end
      end

      def [](key)
        @configurations[key] || raise(ConfigurationError, ErrorMessages.configuration_not_found(key))
      end

      def keys
        @configurations.keys
      end
    end
  end
end

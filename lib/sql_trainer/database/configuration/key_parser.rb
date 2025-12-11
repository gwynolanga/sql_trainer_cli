# frozen_string_literal: true

# lib/sql_trainer/database/configuration/key_parser.rb
module SqlTrainer
  module Database
    class Configuration
      class KeyParser
        ParsedKey = Struct.new(:domain, :adapter)

        attr_reader(:key)

        def initialize(key)
          @key = key
        end

        def parse!
          match = key.match(CONFIGURATION_KEY_PATTERN)
          return ParsedKey.new(match[:domain], match[:adapter]) if match.present?

          raise(ConfigurationError, ErrorMessages.invalid_key_format(key))
        end
      end
    end
  end
end

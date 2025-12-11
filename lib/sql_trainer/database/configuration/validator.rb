# frozen_string_literal: true

# lib/sql_trainer/database/configuration/validator.rb
module SqlTrainer
  module Database
    class Configuration
      class Validator
        attr_reader(:key, :config)

        def initialize(key, config)
          @key = key
          @config = config
        end

        def validate!
          parsed_key = KeyParser.new(key).parse!
          adapter = Validators::AdapterValidator.new(key, config, parsed_key).validate!
          Validators::RequiredOptionsValidator.new(key, config, adapter).validate!
          Validators::DatabaseNameValidator.new(key, config, parsed_key, adapter).validate!
        end
      end
    end
  end
end

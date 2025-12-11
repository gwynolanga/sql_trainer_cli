# frozen_string_literal: true

# lib/sql_trainer/database/configuration/validators/required_options_validator.rb
module SqlTrainer
  module Database
    class Configuration
      module Validators
        class RequiredOptionsValidator
          attr_reader(:key, :config, :adapter)

          def initialize(key, config, adapter)
            @key = key
            @config = config
            @adapter = adapter
          end

          def validate!
            required_options = REQUIRED_OPTIONS[adapter.to_sym]
            missing = required_options.reject { |opt| config.key?(opt) && config[opt].present? }
            return if missing.empty?

            raise(ConfigurationError, ErrorMessages.missing_required_options(key, adapter, missing, required_options))
          end
        end
      end
    end
  end
end

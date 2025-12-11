# frozen_string_literal: true

# lib/sql_trainer/database/configuration/validators/adapter_validator.rb
module SqlTrainer
  module Database
    class Configuration
      module Validators
        class AdapterValidator
          attr_reader(:key, :config, :parsed_key)

          def initialize(key, config, parsed_key)
            @key = key
            @config = config
            @parsed_key = parsed_key
          end

          def validate!
            adapter_from_config = extract_adapter_from_config
            validate_adapter_supported!(adapter_from_config)
            validate_adapter_match!(parsed_key.adapter, adapter_from_config)
            adapter_from_config
          end

          private

          def extract_adapter_from_config
            config["adapter"].presence ||
              raise(ConfigurationError, ErrorMessages.missing_adapter(key, parsed_key.adapter))
          end

          def validate_adapter_supported!(adapter_from_config)
            return if Settings.supported_adapters.include?(adapter_from_config)

            raise(ConfigurationError, ErrorMessages.unsupported_adapter(adapter_from_config))
          end

          def validate_adapter_match!(adapter_from_key, adapter_from_config)
            return if adapter_from_key == adapter_from_config

            raise(ConfigurationError, ErrorMessages.adapter_mismatch(key, adapter_from_key, adapter_from_config))
          end
        end
      end
    end
  end
end

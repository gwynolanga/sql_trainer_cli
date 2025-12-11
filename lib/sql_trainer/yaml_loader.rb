# frozen_string_literal: true

# lib/sql_trainer/yaml_loader.rb
module SqlTrainer
  class YamlLoader
    class << self
      def load_file(file_path, &block)
        validate_file_exists!(file_path)
        data = parse_yaml(file_path)
        block&.call(data)
        deep_freeze(data)
      end

      private

      def validate_file_exists!(file_path)
        return if File.exist?(file_path)

        raise(YamlLoadError, "YAML file not found: '#{file_path}'.")
      end

      def parse_yaml(file_path)
        yaml_content = ERB.new(File.read(file_path)).result
        YAML.safe_load(yaml_content) || {}
      rescue Psych::SyntaxError => e
        raise(YamlLoadError, "Error parsing YAML file '#{file_path}' —> #{e.message}")
      rescue StandardError => e
        raise(YamlLoadError, "Unexpected error reading YAML file '#{file_path}' —> #{e.message}")
      end

      def deep_freeze(obj)
        obj.each_value { |value| deep_freeze(value) } if obj.is_a?(Hash)
        obj.each { |item| deep_freeze(item) } if obj.is_a?(Array)
        obj.freeze
      end
    end
  end
end

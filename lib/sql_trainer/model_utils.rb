# frozen_string_literal: true

# lib/sql_trainer/model_utils.rb
module SqlTrainer
  module ModelUtils
    class << self
      def load_models_from(models_path)
        raise(ModelUtilsError, "Models folder not found: '#{models_path}'.") unless Dir.exist?(models_path)

        model_files = Dir[File.join(models_path, "*.rb")]
        raise(ModelUtilsError, "No model files found in: '#{models_path}'.") if model_files.empty?

        namespace = extract_namespace(models_path)
        model_files.each { |file| load(file) }
        extract_models_from_namespace(namespace)
      end

      def unload_models(classes)
        successfully_removed = classes.select do |klass|
          parent, const_name = find_parent_and_const(klass)
          next false unless can_remove_const?(parent, const_name, klass)

          parent.send(:remove_const, const_name)
          true
        end

        ActiveSupport::DescendantsTracker.clear(successfully_removed)
        successfully_removed
      end

      private

      def extract_namespace(models_path)
        File.basename(models_path).split("_").map(&:capitalize).join
      end

      def extract_models_from_namespace(namespace)
        return [] unless Object.const_defined?(namespace)

        namespace_module = Object.const_get(namespace)
        namespace_module.constants.map { |const_name| namespace_module.const_get(const_name) }.select do |klass|
          klass.is_a?(Class) && klass < ActiveRecord::Base
        end
      end

      def find_parent_and_const(klass)
        parts = klass.name.split("::")
        const_name = parts.pop
        parent = resolve_parent_module(parts)
        [parent, const_name]
      end

      def resolve_parent_module(parts)
        parts.reduce(Object) do |mod, name|
          return nil unless mod.const_defined?(name, false)

          mod.const_get(name, false)
        end
      end

      def can_remove_const?(parent, const_name, klass)
        parent&.const_defined?(const_name, false) && parent.const_get(const_name).equal?(klass)
      end
    end
  end
end

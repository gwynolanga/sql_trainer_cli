# frozen_string_literal: true

# lib/sql_trainer/errors.rb
module SqlTrainer
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class ConnectionError < Error; end
  class InvalidOperationError < Error; end
  class DatabaseNotFoundError < Error; end
  class DatabaseExistsError < Error; end
  class ModelUtilsError < Error; end
  class ResourceNotFoundError < Error; end
  class SeedExecutionError < Error; end
  class TableNotFoundError < Error; end
  class ValidationError < Error; end
  class QueryExecutionError < Error; end
  class YamlLoadError < Error; end
end

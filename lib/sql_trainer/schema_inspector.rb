# frozen_string_literal: true

# lib/sql_trainer/schema_inspector.rb
module SqlTrainer
  class SchemaInspector
    def initialize(database_manager)
      @database_manager = database_manager
    end

    def tables
      @tables ||= connection.tables.reject { |name| Settings.system_tables.include?(name) }.sort
    end

    def table_info(table_name)
      validate_table_exists!(table_name)
      {
        name: table_name,
        columns: columns(table_name),
        indexes: indexes(table_name),
        foreign_keys: foreign_keys(table_name),
        primary_key: primary_key(table_name),
        row_count: row_count(table_name)
      }
    end

    def relationships
      @relationships ||= build_relationships_map
    end

    def table_relationships(table_name)
      validate_table_exists!(table_name)
      relationships[table_name] || {}   # empty hash means: there is a table, but there is no model
    end

    private

    def connection = @database_manager.connection

    def validate_table_exists!(table_name)
      return if tables.include?(table_name)

      raise(TableNotFoundError, "Table not found: '#{table_name}'.")
    end

    def columns(table_name)
      connection.columns(table_name).map do |col|
        {
          name: col.name,
          type: col.type,
          sql_type: col.sql_type,
          null: col.null,
          default: col.default
        }
      end
    end

    def indexes(table_name)
      connection.indexes(table_name).map do |idx|
        {
          name: idx.name,
          columns: idx.columns,
          unique: idx.unique,
          type: idx.type,
          using: idx.using
        }
      end
    end

    def foreign_keys(table_name)
      connection.foreign_keys(table_name).map do |fk|
        {
          name: fk.name,
          column: fk.column,
          to_table: fk.to_table,
          primary_key: fk.primary_key,
          on_delete: fk.on_delete
        }
      end
    end

    def primary_key(table_name) = connection.primary_key(table_name)

    def row_count(table_name)
      quoted_table = connection.quote_table_name(table_name)
      result = connection.execute("SELECT COUNT(*) FROM #{quoted_table}")
      extract_count_from_result(result)
    rescue ActiveRecord::StatementInvalid => e
      warn("Warning: Could not get row count for '#{table_name}' —> #{e.message}".colorize(Settings.color(:warning)))
      nil
    end

    def build_relationships_map
      loaded_models = ActiveRecord::Base.descendants.select(&:table_exists?)
      loaded_models.each_with_object({}) do |model, map|
        map[model.table_name] = build_model_relationships(model)
      end
    end

    def build_model_relationships(model)
      {
        model: model.name,
        has_many: extract_associations(model, :has_many),
        has_one: extract_associations(model, :has_one),
        belongs_to: extract_associations(model, :belongs_to),
        has_and_belongs_to_many: extract_associations(model, :has_and_belongs_to_many)
      }
    end

    def extract_associations(model, association_type)
      model.reflect_on_all_associations(association_type).map do |assoc|
        {
          name: assoc.name,
          class_name: assoc.class_name,
          foreign_key: assoc.foreign_key,
          primary_key: assoc.association_primary_key,
          through: assoc.options[:through],
          dependent: assoc.options[:dependent]
        }
      end
    end

    def extract_count_from_result(result)
      first_row = result.first
      return 0 unless first_row.present?

      first_row["count"]&.to_i || first_row.values.first.to_i
    end
  end
end

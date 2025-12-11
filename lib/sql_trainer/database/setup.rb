# frozen_string_literal: true

# lib/sql_trainer/database/setup.rb
module SqlTrainer
  module Database
    class Setup
      class << self
        def create(database_configuration)
          execute_database_action(database_configuration, :create)
        rescue ActiveRecord::DatabaseAlreadyExists
          raise(DatabaseExistsError, "Database already exists: '#{database_configuration["database"]}'.")
        ensure
          safe_disconnect
        end

        def drop(database_configuration)
          execute_database_action(database_configuration, :drop)
        ensure
          safe_disconnect
        end

        def migrate(database_configuration, migrations_path)
          validate_migrations_path!(migrations_path)
          connect_and_execute(database_configuration) do
            ActiveRecord::MigrationContext.new(migrations_path).migrate
          end
        end

        def rollback(database_configuration, migrations_path, step = 1)
          validate_migrations_path!(migrations_path)
          connect_and_execute(database_configuration) do
            ActiveRecord::MigrationContext.new(migrations_path).rollback(step)
          end
        end

        def seed(database_configuration, models_path, seeds_file)
          validate_seed_file!(seeds_file)
          connect_and_execute(database_configuration) do
            ModelUtils.load_models_from(models_path)
            load(seeds_file)
          end
        rescue ActiveRecord::StatementInvalid => e
          raise(SeedExecutionError, "Seed execution failed —> #{e.message}")
        end

        private

        def execute_database_action(db_config, action)
          adapter = db_config["adapter"]
          adapter == "sqlite3" ? execute_sqlite_action(db_config, action) : execute_sql_action(db_config, action)
        end

        def execute_sql_action(db_config, action)
          ActiveRecord::Base.establish_connection(system_configuration(db_config))
          connection = ActiveRecord::Base.connection
          database = db_config["database"]
          action == :create ? connection.create_database(database) : connection.drop_database(database)
        end

        def execute_sqlite_action(db_config, action)
          if action == :create
            ActiveRecord::Base.establish_connection(db_config)
            ActiveRecord::Base.connection.execute("SELECT 1")
          else
            database_file = db_config["database"]
            File.delete(database_file) if File.exist?(database_file)
          end
        end

        def system_configuration(db_config)
          adapter = db_config["adapter"]
          system_database = Settings.system_databases[adapter]
          db_config.merge("database" => system_database)
        end

        def connect_and_execute(db_config)
          ActiveRecord::Base.establish_connection(db_config)
          yield
        rescue ActiveRecord::NoDatabaseError
          raise(DatabaseNotFoundError, "Database not found: '#{db_config["database"]}'.")
        ensure
          safe_disconnect
        end

        def validate_migrations_path!(path)
          return if path && Dir.exist?(path)

          raise(ResourceNotFoundError, "Migrations folder not found: '#{path}'.")
        end

        def validate_seed_file!(file)
          return if file && File.file?(file) && File.readable?(file)

          raise(ResourceNotFoundError, "Seeds file not found or not readable: '#{file}'.")
        end

        def safe_disconnect
          return unless ActiveRecord::Base.connected?

          ActiveRecord::Base.connection.disconnect!
        rescue StandardError => e
          warn("Warning: Could not disconnect —> #{e.message}".colorize(Settings.color(:warning)))
        end
      end
    end
  end
end

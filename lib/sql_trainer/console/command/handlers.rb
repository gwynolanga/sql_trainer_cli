# frozen_string_literal: true

# lib/sql_trainer/console/command/handlers.rb
module SqlTrainer
  class Console
    module Command
      class Handlers
        def initialize(console)
          @console = console
        end

        def help
          UI.show_commands
          rake_tasks
          UI.show_examples
        end

        def exit
          @console.stop
        end

        def clear
          UI.clear_and_show_welcome
        end

        def rake_tasks
          stdout, _stderr, _status = ::Open3.capture3("rake -T")
          tasks = parse_rake_tasks(stdout)
          display_rake_tasks(tasks)
        rescue StandardError => e
          warn("Warning: Could not fetch rake tasks —> #{e.message}".colorize(Settings.color(:warning)))
        end

        def rake_execute(task_name)
          handle_errors(InvalidOperationError) do
            validate_no_active_connection!(task_name)
            system("rake #{task_name}")
          end
        end

        def configs
          grouped_keys = group_keys_by_domain
          display_grouped_configs(grouped_keys)
        end

        def connect(key)
          puts((Settings.console_message(:connecting) % key).colorize(Settings.color(:warning)))

          handle_errors(DatabaseNotFoundError, ConnectionError, ModelUtilsError) do
            if @console.database_manager.connect(database_configuration[key])
              connection_info
              puts(Settings.console_message(:success_connected).colorize(Settings.color(:success)))
            end
          end
        end

        def disconnect
          if @console.database_manager.connected?
            @console.database_manager.disconnect
            puts(Settings.console_message(:success_disconnected).colorize(Settings.color(:success)))
          else
            puts(Settings.console_message(:no_connection).colorize(Settings.color(:error)))
          end
        end

        def connection_info
          handle_errors(ConfigurationError) do
            info = @console.database_manager.connection_info
            puts(OutputBuilder.build(:connection, info))
          end
        end

        def tables
          tables = @console.schema_inspector.tables
          puts(OutputBuilder.build(:tables_list, tables))
        end

        def describe(table_name)
          handle_errors(TableNotFoundError) do
            info = @console.schema_inspector.table_info(table_name)
            puts(OutputBuilder.build(:table_info, info))
          end
        end

        def relations(table_name = nil)
          handle_errors(TableNotFoundError) do
            if table_name
              relationships = @console.schema_inspector.table_relationships(table_name)
              puts(OutputBuilder.build(:relationships, table_name: table_name, relationships: relationships))
            else
              display_all_relationships
            end
          end
        end

        def sql(query)
          handle_errors(QueryExecutionError, ValidationError) do
            result = @console.query_executor.execute_sql(query)
            puts(OutputBuilder.build(:sql_result, result))
          end
        end

        def activerecord(code)
          handle_errors(QueryExecutionError, ValidationError) do
            result = @console.query_executor.execute_activerecord(code)
            puts(OutputBuilder.build(:ar_result, result))
          end
        end

        def explain(query)
          handle_errors(QueryExecutionError, ValidationError) do
            result = @console.query_executor.explain_sql(query)
            puts(OutputBuilder.build(:explain, result))
          end
        end

        private

        def database_configuration = @console.database_configuration

        def handle_errors(*error_classes)
          yield
        rescue *error_classes => e
          UI.show_error(e.message)
        end

        def validate_no_active_connection!(task_name)
          return unless @console.database_manager.connected?

          current_database = @console.database_manager.database
          message = Settings.console_message(:rake_while_connected) % [task_name, current_database]
          raise(InvalidOperationError, message)
        end

        def parse_rake_tasks(stdout)
          stdout.split("\n").map do |str|
            name, description = str.split(/\s+(?=#)/)
            { name: name, description: description }
          end
        end

        def display_rake_tasks(tasks)
          return if tasks.empty?

          max_task_name = tasks.map { |task| task[:name].size }.max

          UI.print_section("Available Rake Tasks") do
            tasks.each do |task|
              name = task[:name].ljust(max_task_name + 2).colorize(Settings.color(:success))
              description = task[:description].colorize(Settings.color(:warning))
              puts("  #{name} #{description}")
            end
          end
        end

        def group_keys_by_domain
          database_configuration.keys.group_by { |key| Database::Configuration.extract_domain(key) }
        end

        def display_grouped_configs(grouped_keys)
          UI.print_section("Available Database Configuration Keys") do
            grouped_keys.each_with_index do |(domain, keys), index|
              puts("For #{domain}:".colorize(Settings.color(:warning)))

              keys.each do |key|
                adapter = database_configuration[key]["adapter"]
                database = database_configuration[key]["database"]
                puts("  - #{key.ljust(30)}".colorize(Settings.color(:success)) +
                     " # (#{adapter} —> #{database})".colorize(Settings.color(:secondary)))
              end

              puts("\n") if index < grouped_keys.count - 1
            end
          end
        end

        def display_all_relationships
          all_relationships = @console.schema_inspector.relationships

          if all_relationships.empty?
            puts(Settings.schema_message(:no_models).colorize(Settings.color(:warning)))
          else
            all_relationships.each do |table_name, relationships|
              puts(OutputBuilder.build(:relationships, table_name: table_name, relationships: relationships))
            end
          end
        end
      end
    end
  end
end

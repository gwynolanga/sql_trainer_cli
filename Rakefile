# frozen_string_literal: true

require("bundler/setup")
require("active_support")
require("active_support/core_ext")
require_relative("lib/sql_trainer")

namespace :db do
  desc("Create a new database")
  task(:create, [:key]) { |_t, args| execute_db_task(args[:key], :create) }

  desc("Drop an existing database")
  task(:drop, [:key]) { |_t, args| execute_db_task(args[:key], :drop) }

  desc("Run migrations to an existing database")
  task(:migrate, [:key]) { |_t, args| execute_db_task(args[:key], :migrate) }

  desc("Revert migrations from an existing database")
  task(:rollback, [:key, :step]) { |_t, args| execute_db_task(args[:key], :rollback, args[:step]) }

  desc("Populate an existing database with data")
  task(:seed, [:key]) { |_t, args| execute_db_task(args[:key], :seed) }

  desc("Reset the database (drop, create, migrate, seed)")
  task(:reset, [:key]) { |_t, args| invoke_tasks(args[:key], %w[drop create migrate seed]) }

  desc("Configure all databases (create, migrate, seed)")
  task(:setup) do
    SqlTrainer::Database::Configuration.new.keys.each do |key|
      puts(" Database Configuration Key: #{key} ".center(100, "=").colorize(:light_cyan))
      invoke_tasks(key, %w[create migrate seed])
    end
    puts(" All databases are configured! ".center(100, "=").colorize(:light_cyan))
  end
end

def execute_db_task(key, action, step = nil)
  domain = SqlTrainer::Database::Configuration.extract_domain(key)
  db_config = SqlTrainer::Database::Configuration.new[key]
  message = perform_action(domain, db_config, action, step)
  puts(message.colorize(:light_green))
rescue StandardError => e
  puts(e.message.colorize(:light_red))
end

def perform_action(domain, db_config, action, step = nil)
  case action
  when :create
    SqlTrainer::Database::Setup.create(db_config)
    "Database '#{db_config["database"]}' created!"
  when :drop
    SqlTrainer::Database::Setup.drop(db_config)
    "Database '#{db_config["database"]}' dropped!"
  when :migrate
    migrations_path = SqlTrainer.migrations_path_for(domain)
    SqlTrainer::Database::Setup.migrate(db_config, migrations_path)
    "Migrations for database '#{db_config["database"]}' completed!"
  when :rollback
    step_count = (step || 1).to_i
    migrations_path = SqlTrainer.migrations_path_for(domain)
    SqlTrainer::Database::Setup.rollback(db_config, migrations_path, step_count)
    "#{step_count} migration(s) for database '#{db_config["database"]}' reverted!"
  else
    models_path = SqlTrainer.models_path_for(domain)
    seeds_file = SqlTrainer.seeds_file_for(domain)
    SqlTrainer::Database::Setup.seed(db_config, models_path, seeds_file)
    "Database '#{db_config["database"]}' seeded!"
  end
end

def invoke_tasks(key, task_names)
  task_names.each do |task_name|
    Rake::Task["db:#{task_name}"].invoke(key)
    Rake::Task["db:#{task_name}"].reenable
  end
end

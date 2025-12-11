# frozen_string_literal: true

# lib/sql_trainer.rb
require("active_record")
require("colorize")
require("dotenv/load")
require("erb")
require("readline")
require("terminal-table")
require("yaml")
require("open3")

module SqlTrainer
  class << self
    def root_path
      @root_path ||= File.expand_path("..", __dir__)
    end

    def database_configuration_file
      @database_configuration_file ||= File.join(root_path, "config", "database.yml")
    end

    def settings_file
      @settings_file ||= File.join(root_path, "config", "settings.yml")
    end

    def seeds_file_for(domain) = File.join(root_path, "db", domain, "seeds.rb")
    def migrations_path_for(domain) = File.join(root_path, "db", domain, "migrate")
    def models_path_for(domain) = File.join(root_path, "models", domain)

    def load_components
      Dir[File.join(__dir__, "sql_trainer", "**", "*.rb")].sort.each { |file| require(file) }
    end

    def load_settings
      Settings.load_file(settings_file) if File.exist?(settings_file)
    end
  end
end

SqlTrainer.load_components
SqlTrainer.load_settings

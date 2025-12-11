# frozen_string_literal: true

# lib/sql_trainer/console/command/registry.rb
module SqlTrainer
  class Console
    module Command
      class Registry
        COMMANDS = [
          { name: "help", pattern: /^(?:help|h|\?)$/, handler: :help,
            description: "Show commands help (also: h, ?)" },
          { name: "exit", pattern: /^(?:exit|quit|q)$/, handler: :exit,
            description: "Exit the console (also: quit, q)" },
          { name: "clear", pattern: /^(?:clear|cls)$/, handler: :clear,
            description: "Clear the screen (also: cls)" },
          { name: "rake tasks", pattern: /^rake tasks$/, handler: :rake_tasks,
            description: "Show a list of available rake tasks" },
          { name: "rake <task>", pattern: /^rake\s+(db:.+)$/, handler: :rake_execute,
            description: "Execute Rake task" },
          { name: "configs", pattern: /^configs$/, handler: :configs,
            description: "Show available configuration keys from database.yml" },
          { name: "connect <key>", pattern: /^connect\s+(\w+)$/, handler: :connect,
            description: "Connect to the database by key" },
          { name: "connection", pattern: /^connection$/, handler: :connection_info,
            description: "Show active connection information" },
          { name: "disconnect", pattern: /^disconnect$/, handler: :disconnect,
            description: "Disconnect from the current database" },
          { name: "tables", pattern: /^tables$/, handler: :tables,
            description: "Show a list of tables in the current database" },
          { name: "describe <table>", pattern: /^(?:describe|desc)\s+(\w+)$/, handler: :describe,
            description: "Show table structure (also: desc)" },
          { name: "relations <table>", pattern: /^(?:relations|rels)(?:\s+(\w+))?$/, handler: :relations,
            description: "Show relationships between tables (also: rels)" },
          { name: "sql <query>", pattern: /^(?:sql\s+|)(select\s+.+)$/i, handler: :sql,
            description: "Execute SQL query (sql can be omitted)" },
          { name: "ar <code>", pattern: /^ar\s+(.+)$/i, handler: :activerecord,
            description: "Execute ActiveRecord query (ar can be omitted)" },
          { name: "explain <query>", pattern: /^explain\s+(.+)$/i, handler: :explain,
            description: "Show SQL query execution plan" }
        ].freeze

        AR_PATTERNS = [
          /\A\w+\.(find|where|select|joins|includes|group|order|limit|count|sum|average|pluck|first|last|all)/,
          /\A\w+::/
        ].freeze

        private_constant(:COMMANDS, :AR_PATTERNS)

        def self.all_commands = COMMANDS
        def self.command_patterns = all_commands.map { |cmd| [cmd[:pattern], cmd[:handler]] }
        def self.looks_like_activerecord?(input) = AR_PATTERNS.any? { |pattern| input.match?(pattern) }
      end
    end
  end
end

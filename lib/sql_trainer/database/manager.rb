# frozen_string_literal: true

# lib/sql_trainer/database/manager.rb
module SqlTrainer
  module Database
    class Manager
      def initialize
        @configuration = {}
        @connected = false
        @loaded_models = []
      end

      def connect(configuration)
        disconnect if connected?

        ActiveRecord::Base.establish_connection(configuration)
        ActiveRecord::Base.connection.connect!
        @configuration = configuration
        @connected = true
        @loaded_models = ModelUtils.load_models_from(SqlTrainer.models_path_for(domain))

        true
      rescue ActiveRecord::NoDatabaseError
        raise(DatabaseNotFoundError, "Database not found: '#{database}'.")
      rescue ActiveRecord::ConnectionNotEstablished => e
        raise(ConnectionError, "Failed to establish connection —> #{e.message}")
      end

      def connected?
        @connected && ActiveRecord::Base.connection.active?
      rescue ActiveRecord::ConnectionNotEstablished
        false
      end

      def disconnect
        return false unless connected?

        ActiveRecord::Base.connection.disconnect!
        ModelUtils.unload_models(@loaded_models)
        @configuration = {}
        @connected = false
        @loaded_models.clear

        true
      end

      def domain
        adapter == "sqlite3" ? File.basename(File.dirname(database)) : database
      end

      def adapter = @configuration["adapter"]
      def database = @configuration["database"]

      def connection
        raise(ConnectionError, "No active connection to the database.") unless connected?
        ActiveRecord::Base.connection
      end

      def connection_info
        connected? ? { domain: domain, adapter: adapter, database: database } : nil
      end
    end
  end
end

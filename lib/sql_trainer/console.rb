# frozen_string_literal: true

# lib/sql_trainer/console.rb
module SqlTrainer
  class Console
    attr_reader(:database_configuration, :database_manager, :query_executor, :schema_inspector)

    def initialize
      @running = false
      @database_configuration = Database::Configuration.new
      @database_manager = Database::Manager.new
      @query_executor = Query::Executor.new(@database_manager)
      @schema_inspector = SchemaInspector.new(@database_manager)
      @command_processor = Command::Processor.new(self)
    end

    def start
      UI.clear_and_show_welcome
      @running = true

      run_loop while @running

      UI.show_goodbye
    end

    def stop
      @running = false
    end

    private

    def run_loop
      input = read_input
      return if input.blank?

      @command_processor.process(input.strip)
    rescue Interrupt
      UI.show_interrupt
    rescue StandardError => e
      UI.show_error(e.message)
    end

    def read_input
      prompt = build_prompt
      input = Readline.readline(prompt, true)
      Readline::HISTORY.pop if input.blank?
      input
    end

    def build_prompt
      return Settings.prompt_disconnected.colorize(Settings.color(:muted)) unless database_manager.connected?

      (Settings.prompt_connected % database_manager.database).colorize(Settings.color(:info))
    end
  end
end

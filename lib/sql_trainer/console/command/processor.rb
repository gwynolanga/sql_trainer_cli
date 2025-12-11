# frozen_string_literal: true

# lib/sql_trainer/console/command/processor.rb
module SqlTrainer
  class Console
    module Command
      class Processor
        def initialize(console)
          @handlers = Handlers.new(console)
          @command_patterns = Registry.command_patterns
        end

        def process(input)
          @command_patterns.each do |pattern, handler_name|
            match = input.match(pattern)
            return @handlers.public_send(handler_name, *match.captures) if match.present?
          end

          if Registry.looks_like_activerecord?(input)
            @handlers.activerecord(input)
          else
            UI.show_unknown_command
          end
        end
      end
    end
  end
end

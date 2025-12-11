# frozen_string_literal: true

# lib/sql_trainer/console/ui.rb
module SqlTrainer
  class Console
    class UI
      class << self
        def clear_and_show_welcome
          clear_screen
          show_welcome
        end

        def clear_screen
          system("clear") || system("cls")
        end

        def show_welcome
          width = Settings.output_width
          separator = "=" * width

          puts("\n#{separator}".colorize(Settings.color(:primary)))
          puts(Settings.console_message(:welcome_title).center(width).colorize(Settings.color(:secondary)).bold)
          puts(Settings.console_message(:welcome_subtitle).center(width).colorize(Settings.color(:info)).bold)
          puts("#{separator}".colorize(Settings.color(:primary)))
          puts(Settings.console_message(:help).colorize(Settings.color(:warning)))
        end

        def show_goodbye
          puts(Settings.console_message(:goodbye).colorize(Settings.color(:primary)))
        end

        def show_interrupt
          puts(Settings.console_message(:interrupt).colorize(Settings.color(:warning)))
        end

        def show_error(message)
          puts("#{message}".colorize(Settings.color(:error)))
        end

        def show_unknown_command
          puts(Settings.console_message(:unknown_command).colorize(Settings.color(:error)))
        end

        def print_section(title)
          width = Settings.output_width
          separator = "=" * width

          puts(" #{title} ".center(width, "=").colorize(Settings.color(:primary)))
          yield
          puts("#{separator}".colorize(Settings.color(:primary)))
        end

        def show_commands
          print_section("Available Commands") do
            Command::Registry.all_commands.each do |command|
              name = command[:name].ljust(35).colorize(Settings.color(:success))
              description = "# #{command[:description]}".colorize(Settings.color(:warning))
              puts("  #{name} #{description}")
            end
          end
        end

        def show_examples
          examples = [
            ["configs", ""],
            %w[rake db:reset[learn_hub_postgresql]],
            %w[connect learn_hub_postgresql],
            ["sql", "SELECT * FROM categories LIMIT 5"],
            %w[ar LearnHub::Category.limit(5)],
            ["", "SELECT * FROM users LIMIT 10"],
            ["", "LearnHub::User.limit(10)"],
            %w[describe categories],
            %w[relations users],
            ["disconnect", ""]
          ]

          puts("Examples:".colorize(Settings.color(:warning)))
          examples.each { |command, arg| puts("  #{format_example_line(command, arg)}") }
        end

        private

        def format_example_line(command, arg)
          if command.blank?
            arg.colorize(Settings.color(:secondary))
          elsif arg.blank?
            command.colorize(Settings.color(:success))
          else
            "#{command.colorize(Settings.color(:success))} #{arg.colorize(Settings.color(:secondary))}"
          end
        end
      end
    end
  end
end

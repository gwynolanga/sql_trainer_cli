# frozen_string_literal: true

# lib/sql_trainer/components/value_formatter.rb
module SqlTrainer
  module Components
    class ValueFormatter
      class << self
        def format(value)
          case value
          when NilClass then "NULL".colorize(Settings.color(:muted))
          when TrueClass then value.to_s.upcase.colorize(Settings.color(:success))
          when FalseClass then value.to_s.upcase.colorize(Settings.color(:error))
          when Numeric then value.to_s.colorize(Settings.color(:warning))
          when Time, Date then value.to_s.colorize(Settings.color(:info))
          else truncate(value)
          end
        end

        private

        def truncate(value)
          string = value.to_s
          max = Settings.max_string_length
          string.length > max ? "#{string[0..(max - 3)]}..." : string
        end
      end
    end
  end
end

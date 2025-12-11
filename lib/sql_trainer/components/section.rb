# frozen_string_literal: true

# lib/sql_trainer/components/section.rb
module SqlTrainer
  module Components
    class Section
      extend(Components::Colorizable)

      class << self
        def build(title)
          width = Settings.output_width
          separator = "=" * width

          output = [centered_title(title, width)]
          output.concat(Array(yield))
          output << colorize(separator, :primary)
          output.join("\n")
        end

        private

        def centered_title(title, width)
          colorize(" #{title} ".center(width, "="), :primary)
        end
      end
    end
  end
end

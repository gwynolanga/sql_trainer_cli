# frozen_string_literal: true

# lib/sql_trainer/components/colorizable.rb
module SqlTrainer
  module Components
    module Colorizable
      private

      def colorize(text, color_key)
        text.to_s.colorize(Settings.color(color_key))
      end
    end
  end
end

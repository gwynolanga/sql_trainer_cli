# frozen_string_literal: true

# lib/sql_trainer/query/validator.rb
module SqlTrainer
  module Query
    class Validator
      DANGEROUS_SQL_PATTERNS = [
        /;\s*(INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|TRUNCATE)/i,
        /UNION.*SELECT.*INTO/i,
        /INTO\s+OUTFILE/i,
        /LOAD_FILE/i
      ].freeze

      DANGEROUS_RUBY_PATTERNS = [
        /\beval\s*\(/i,
        /\bexec\s*\(/i,
        /\bsystem\s*\(/i,
        /`[^`]+`/,                      # backticks
        /%x\{/,                         # %x{} construction
        /File\.(delete|unlink|write)/i,
        /Dir\.(delete|rmdir)/i,
        /ActiveRecord::Base\.connection\.(execute|exec_query|exec_insert|exec_update|exec_delete)/i
      ].freeze

      private_constant(:DANGEROUS_SQL_PATTERNS, :DANGEROUS_RUBY_PATTERNS)

      class << self
        def validate_sql!(query)
          validate_query!(query, :sql) do |normalized|
            check_forbidden_commands!(normalized, Settings.forbidden_sql_commands, :sql)
            check_dangerous_patterns!(normalized, DANGEROUS_SQL_PATTERNS, :sql)
          end
        end

        def validate_activerecord!(code)
          validate_query!(code, :ar) do |normalized|
            check_forbidden_commands!(normalized, Settings.forbidden_ar_methods, :ar)
            check_dangerous_patterns!(normalized, DANGEROUS_RUBY_PATTERNS, :ar)
          end
        end

        private

        def validate_query!(query, type)
          error_key = type == :sql ? :empty_sql : :empty_ar
          raise(ValidationError, Settings.validator_message(error_key)) if query.blank?

          normalized = normalize_query(query)
          yield(normalized)
        end

        def normalize_query(query)
          query.gsub(/--.*$/, "")          # single-line comments
               .gsub(%r{/\*.*?\*/}m, "")   # multi-line comments
               .gsub(/\s+/, " ")           # multiple spaces
               .strip
               .downcase
        end

        def check_forbidden_commands!(query, forbidden_list, type)
          return if forbidden_list.empty?

          pattern = build_forbidden_pattern(type, forbidden_list)
          match = query.match(pattern)
          return unless match.present?

          message_key = type == :sql ? :forbidden_sql : :forbidden_ar
          message = Settings.validator_message(message_key) % match[1]
          raise(ValidationError, message)
        end

        def build_forbidden_pattern(type, forbidden_list)
          escaped_list = forbidden_list.map { |m| Regexp.escape(m) }.join('|')
          type == :sql ? /^\s*(#{escaped_list})\s+/im : /\.(#{escaped_list})(?:\(|\s|$)/
        end

        def check_dangerous_patterns!(query, patterns, type)
          patterns.each do |pattern|
            match = query.match(pattern)
            next unless match.present?

            message_key = type == :sql ? :dangerous_sql : :dangerous_ar
            message = Settings.validator_message(message_key) % match.to_s
            raise(ValidationError, message)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module LearnHub
  class Submission < ActiveRecord::Base
    self.table_name = :submissions

    belongs_to :assignment
    belongs_to :user

    validates :content, presence: true
    validates :status, presence: true, inclusion: { in: %w[pending reviewed graded] }
    validates :score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :submitted_at, presence: true
    validates :assignment_id, :user_id, presence: true
  end
end

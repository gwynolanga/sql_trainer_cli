# frozen_string_literal: true

module LearnHub
  class QuizAttempt < ActiveRecord::Base
    self.table_name = :quiz_attempts

    belongs_to :quiz
    belongs_to :user
    has_many :user_answers, dependent: :destroy

    validates :score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :started_at, presence: true
    validates :quiz_id, :user_id, presence: true
  end
end

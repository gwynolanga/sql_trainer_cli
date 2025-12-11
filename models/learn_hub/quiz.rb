# frozen_string_literal: true

module LearnHub
  class Quiz < ActiveRecord::Base
    self.table_name = :quizzes

    belongs_to :lesson
    has_many :questions, dependent: :destroy
    has_many :quiz_attempts, dependent: :destroy

    validates :title, presence: true
    validates :passing_score, presence: true, numericality: { greater_than: 0 }
    validates :time_limit_minutes, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
    validates :lesson_id, presence: true
  end
end

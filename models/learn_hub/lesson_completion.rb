# frozen_string_literal: true

module LearnHub
  class LessonCompletion < ActiveRecord::Base
    self.table_name = :lesson_completions

    belongs_to :lesson
    belongs_to :user

    validates :user_id, uniqueness: { scope: :lesson_id, message: "already completed the lesson" }
    validates :completed_at, presence: true
    validates :lesson_id, :user_id, presence: true
  end
end

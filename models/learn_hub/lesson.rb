# frozen_string_literal: true

module LearnHub
  class Lesson < ActiveRecord::Base
    self.table_name = :lessons

    belongs_to :mod, class_name: "Module", foreign_key: :module_id
    has_many :assignments, dependent: :destroy
    has_many :lesson_completions, dependent: :destroy
    has_many :quizzes, dependent: :destroy

    validates :title, presence: true
    validates :content_type, presence: true, inclusion: { in: %w[video text pdf] }
    validates :duration_minutes, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
    validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :module_id, presence: true
  end
end

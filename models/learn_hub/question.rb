# frozen_string_literal: true

module LearnHub
  class Question < ActiveRecord::Base
    self.table_name = :questions

    belongs_to :quiz
    has_many :answers, dependent: :destroy
    has_many :user_answers, dependent: :destroy

    validates :content, presence: true
    validates :question_type, presence: true, inclusion: { in: %w[single_choice multiple_choice text] }
    validates :points, presence: true, numericality: { greater_than: 0 }
    validates :quiz_id, presence: true
  end
end

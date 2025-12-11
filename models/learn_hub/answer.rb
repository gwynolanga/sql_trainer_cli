# frozen_string_literal: true

module LearnHub
  class Answer < ActiveRecord::Base
    self.table_name = :answers

    belongs_to :question
    has_many :user_answers, dependent: :nullify

    validates :content, presence: true
    validates :question_id, presence: true
  end
end

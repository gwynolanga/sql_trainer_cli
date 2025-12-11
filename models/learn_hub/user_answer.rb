# frozen_string_literal: true

module LearnHub
  class UserAnswer < ActiveRecord::Base
    self.table_name = :user_answers

    belongs_to :quiz_attempt
    belongs_to :question
    belongs_to :answer, optional: true
    belongs_to :user

    validates :quiz_attempt_id, :question_id, :user_id, presence: true
  end
end

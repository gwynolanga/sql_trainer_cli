# frozen_string_literal: true

module LearnHub
  class Review < ActiveRecord::Base
    self.table_name = :reviews

    belongs_to :course
    belongs_to :user

    validates :rating, presence: true, numericality: { only_integer: true, in: 1..5 }
    validates :user_id, uniqueness: { scope: :course_id, message: "already left a review" }
    validates :created_at, presence: true
  end
end

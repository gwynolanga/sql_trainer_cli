# frozen_string_literal: true

module LearnHub
  class Enrollment < ActiveRecord::Base
    self.table_name = :enrollments

    belongs_to :user
    belongs_to :course

    validates :user_id, uniqueness: { scope: :course_id, message: "already enrolled in this course" }
    validates :status, presence: true, inclusion: { in: %w[active completed cancelled] }
    validates :enrolled_at, presence: true
  end
end

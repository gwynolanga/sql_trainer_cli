# frozen_string_literal: true

module LearnHub
  class Certificate < ActiveRecord::Base
    self.table_name = :certificates

    belongs_to :course
    belongs_to :user

    validates :certificate_number, presence: true, uniqueness: true
    validates :issued_at, presence: true
    validates :course_id, :user_id, presence: true
  end
end

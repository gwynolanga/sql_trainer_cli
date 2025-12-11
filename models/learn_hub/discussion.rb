# frozen_string_literal: true

module LearnHub
  class Discussion < ActiveRecord::Base
    self.table_name = :discussions

    belongs_to :course
    belongs_to :user
    has_many :discussion_replies, dependent: :destroy

    validates :title, :content, presence: true
    validates :created_at, presence: true
    validates :course_id, :user_id, presence: true
  end
end

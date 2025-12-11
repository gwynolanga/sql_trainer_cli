# frozen_string_literal: true

module LearnHub
  class DiscussionReply < ActiveRecord::Base
    self.table_name = :discussion_replies

    belongs_to :discussion
    belongs_to :user

    validates :content, presence: true
    validates :created_at, presence: true
    validates :discussion_id, :user_id, presence: true
  end
end

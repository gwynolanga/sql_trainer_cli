# frozen_string_literal: true

module LearnHub
  class Assignment < ActiveRecord::Base
    self.table_name = :assignments

    belongs_to :lesson
    has_many :submissions, dependent: :destroy

    validates :title, :description, presence: true
    validates :max_score, presence: true, numericality: { greater_than: 0 }
    validates :lesson_id, presence: true
  end
end

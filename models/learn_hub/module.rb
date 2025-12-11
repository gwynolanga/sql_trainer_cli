# frozen_string_literal: true

module LearnHub
  class Module < ActiveRecord::Base
    self.table_name = :modules

    belongs_to :course
    has_many :lessons, -> { order(position: :asc) }, dependent: :destroy

    validates :title, presence: true
    validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :course_id, presence: true
  end
end

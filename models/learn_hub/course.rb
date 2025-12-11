# frozen_string_literal: true

module LearnHub
  class Course < ActiveRecord::Base
    self.table_name = :courses

    belongs_to :instructor, class_name: "User", foreign_key: :instructor_id, optional: true
    belongs_to :category
    has_many :modules, -> { order(position: :asc) }, dependent: :destroy
    has_many :lessons, through: :modules
    has_many :enrollments, dependent: :destroy
    has_many :students, through: :enrollments, source: :user
    has_many :reviews, dependent: :destroy
    has_many :certificates, dependent: :destroy
    has_many :payments, dependent: :destroy
    has_many :discussions, dependent: :destroy

    validates :title, presence: true
    validates :description, presence: true
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :level, presence: true, inclusion: { in: %w[beginner intermediate advanced] }
    validates :instructor_id, :category_id, presence: true
  end
end

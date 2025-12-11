# frozen_string_literal: true

module LearnHub
  class User < ActiveRecord::Base
    self.table_name = :users

    has_many :enrollments, dependent: :destroy
    has_many :courses, through: :enrollments
    has_many :created_courses, class_name: "Course", foreign_key: :instructor_id, dependent: :nullify
    has_many :submissions, dependent: :destroy
    has_many :reviews, dependent: :destroy
    has_many :certificates, dependent: :destroy
    has_many :payments, dependent: :destroy
    has_many :lesson_completions, dependent: :destroy
    has_many :discussions, dependent: :destroy
    has_many :discussion_replies, dependent: :destroy
    has_many :quiz_attempts, dependent: :destroy
    has_many :user_answers, dependent: :destroy

    belongs_to :role

    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :first_name, :last_name, presence: true
    validates :role_id, presence: true
  end
end

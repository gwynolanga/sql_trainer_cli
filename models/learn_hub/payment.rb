# frozen_string_literal: true

module LearnHub
  class Payment < ActiveRecord::Base
    self.table_name = :payments

    belongs_to :course
    belongs_to :user

    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :status, presence: true, inclusion: { in: %w[pending completed failed refunded] }
    validates :payment_method, presence: true
    validates :paid_at, presence: true
    validates :course_id, :user_id, presence: true
  end
end

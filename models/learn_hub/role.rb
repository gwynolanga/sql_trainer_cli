# frozen_string_literal: true

module LearnHub
  class Role < ActiveRecord::Base
    self.table_name = :roles

    has_many :users, dependent: :restrict_with_error

    validates :name, presence: true, uniqueness: true
    validates :name, inclusion: { in: %w[student instructor admin] }
  end
end

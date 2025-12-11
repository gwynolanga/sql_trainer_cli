# frozen_string_literal: true

module LearnHub
  class Category < ActiveRecord::Base
    self.table_name = :categories

    has_many :courses, dependent: :restrict_with_error
    belongs_to :parent_category, class_name: "Category", optional: true
    has_many :subcategories, class_name: "Category", foreign_key: :parent_category_id, dependent: :nullify

    validates :name, presence: true, uniqueness: { scope: :parent_category_id }
  end
end

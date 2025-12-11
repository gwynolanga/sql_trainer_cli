# frozen_string_literal: true

class CreateCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.string :level, null: false
      t.string :language, default: "en"
      t.string :thumbnail_url
      t.boolean :is_published, default: false
      t.references :instructor, foreign_key: { to_table: :users, on_delete: :nullify }
      t.references :category, null: false, foreign_key: { on_delete: :restrict }

      t.timestamps
    end

    add_index :courses, :title
    add_index :courses, :level
    add_index :courses, :is_published
    add_index :courses, :created_at
  end
end

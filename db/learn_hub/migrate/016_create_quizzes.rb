# frozen_string_literal: true

class CreateQuizzes < ActiveRecord::Migration[7.0]
  def change
    create_table :quizzes do |t|
      t.string :title, null: false
      t.text :description
      t.decimal :passing_score, precision: 5, scale: 2, null: false
      t.integer :time_limit_minutes
      t.integer :max_attempts
      t.references :lesson, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end

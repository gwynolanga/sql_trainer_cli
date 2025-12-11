# frozen_string_literal: true

class CreateLessonCompletions < ActiveRecord::Migration[7.0]
  def change
    create_table :lesson_completions do |t|
      t.references :lesson, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :completed_at, null: false

      t.timestamps
    end

    add_index :lesson_completions, [:user_id, :lesson_id], unique: true
    add_index :lesson_completions, :completed_at
  end
end

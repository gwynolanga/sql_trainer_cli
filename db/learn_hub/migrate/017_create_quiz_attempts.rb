# frozen_string_literal: true

class CreateQuizAttempts < ActiveRecord::Migration[7.0]
  def change
    create_table :quiz_attempts do |t|
      t.references :quiz, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.decimal :score, precision: 5, scale: 2
      t.datetime :started_at, null: false
      t.datetime :completed_at
      t.boolean :is_passed

      t.timestamps
    end

    add_index :quiz_attempts, [:user_id, :quiz_id]
    add_index :quiz_attempts, :started_at
  end
end

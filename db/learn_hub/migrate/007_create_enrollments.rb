# frozen_string_literal: true

class CreateEnrollments < ActiveRecord::Migration[7.0]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :enrolled_at, null: false
      t.string :status, null: false, default: "active"
      t.integer :progress_percentage, default: 0
      t.datetime :completed_at

      t.timestamps
    end

    add_index :enrollments, [:user_id, :course_id], unique: true
    add_index :enrollments, :status
    add_index :enrollments, :enrolled_at
  end
end

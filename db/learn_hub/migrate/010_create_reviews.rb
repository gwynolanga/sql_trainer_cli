# frozen_string_literal: true

class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.integer :rating, null: false
      t.text :comment

      t.timestamps
    end

    add_index :reviews, [:user_id, :course_id], unique: true
    add_index :reviews, :rating
    add_index :reviews, :created_at
  end
end

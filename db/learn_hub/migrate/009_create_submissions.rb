# frozen_string_literal: true

class CreateSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :submissions do |t|
      t.references :assignment, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.text :content, null: false
      t.string :file_url
      t.decimal :score, precision: 5, scale: 2
      t.text :feedback
      t.string :status, null: false, default: "pending"
      t.datetime :submitted_at, null: false
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :submissions, [:assignment_id, :user_id]
    add_index :submissions, :status
    add_index :submissions, :submitted_at
  end
end

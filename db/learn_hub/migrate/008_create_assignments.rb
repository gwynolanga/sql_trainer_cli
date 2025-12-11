# frozen_string_literal: true

class CreateAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.decimal :max_score, precision: 5, scale: 2, null: false
      t.datetime :due_date
      t.references :lesson, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :assignments, :due_date
  end
end

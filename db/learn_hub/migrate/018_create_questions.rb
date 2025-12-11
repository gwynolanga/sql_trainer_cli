# frozen_string_literal: true

class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.references :quiz, null: false, foreign_key: { on_delete: :cascade }
      t.text :content, null: false
      t.string :question_type, null: false
      t.decimal :points, precision: 5, scale: 2, null: false
      t.text :explanation

      t.timestamps
    end

    add_index :questions, :question_type
  end
end

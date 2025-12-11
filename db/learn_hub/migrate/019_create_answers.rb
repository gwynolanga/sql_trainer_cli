# frozen_string_literal: true

class CreateAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :answers do |t|
      t.references :question, null: false, foreign_key: { on_delete: :cascade }
      t.text :content, null: false
      t.boolean :is_correct, default: false

      t.timestamps
    end

    add_index :answers, [:question_id, :is_correct]
  end
end

# frozen_string_literal: true

class CreateUserAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :user_answers do |t|
      t.references :quiz_attempt, null: false, foreign_key: { on_delete: :cascade }
      t.references :question, null: false, foreign_key: { on_delete: :cascade }
      t.references :answer, foreign_key: { on_delete: :nullify }
      t.text :text_answer
      t.references :user, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :user_answers, [:quiz_attempt_id, :question_id]
  end
end

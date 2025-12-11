# frozen_string_literal: true

class CreateDiscussions < ActiveRecord::Migration[7.0]
  def change
    create_table :discussions do |t|
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :title, null: false
      t.text :content, null: false
      t.integer :views_count, default: 0
      t.boolean :is_pinned, default: false

      t.timestamps
    end

    add_index :discussions, :created_at
    add_index :discussions, :is_pinned
    add_index :discussions, :views_count
  end
end

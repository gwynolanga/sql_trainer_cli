# frozen_string_literal: true

class CreateLessons < ActiveRecord::Migration[7.0]
  def change
    create_table :lessons do |t|
      t.string :title, null: false
      t.text :description
      t.text :content
      t.string :content_type, null: false
      t.string :video_url
      t.string :file_url
      t.integer :duration_minutes
      t.integer :position, null: false
      t.boolean :is_preview, default: false
      t.references :module, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :lessons, [:module_id, :position]
    add_index :lessons, :content_type
  end
end

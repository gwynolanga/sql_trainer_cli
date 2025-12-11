# frozen_string_literal: true

class CreateModules < ActiveRecord::Migration[7.0]
  def change
    create_table :modules do |t|
      t.string :title, null: false
      t.text :description
      t.integer :position, null: false
      t.references :course, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :modules, [:course_id, :position]
  end
end

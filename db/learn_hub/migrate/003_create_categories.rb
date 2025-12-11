# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.references :parent_category, foreign_key: { to_table: :categories, on_delete: :nullify }

      t.timestamps
    end

    add_index :categories, [:name, :parent_category_id], unique: true
  end
end

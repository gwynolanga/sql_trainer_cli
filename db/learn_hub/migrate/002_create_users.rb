# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone
      t.date :date_of_birth
      t.text :bio
      t.string :avatar_url
      t.references :role, null: false, foreign_key: { on_delete: :restrict }

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end

# frozen_string_literal: true

class CreateCertificates < ActiveRecord::Migration[7.0]
  def change
    create_table :certificates do |t|
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :certificate_number, null: false
      t.datetime :issued_at, null: false
      t.string :certificate_url

      t.timestamps
    end

    add_index :certificates, :certificate_number, unique: true
    add_index :certificates, [:user_id, :course_id]
    add_index :certificates, :issued_at
  end
end

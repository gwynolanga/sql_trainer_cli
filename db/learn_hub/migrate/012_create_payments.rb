# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: "USD"
      t.string :status, null: false, default: "pending"
      t.string :payment_method, null: false
      t.string :transaction_id
      t.datetime :paid_at, null: false

      t.timestamps
    end

    add_index :payments, :transaction_id, unique: true
    add_index :payments, [:user_id, :course_id]
    add_index :payments, :status
    add_index :payments, :paid_at
  end
end

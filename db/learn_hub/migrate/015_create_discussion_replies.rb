# frozen_string_literal: true

class CreateDiscussionReplies < ActiveRecord::Migration[7.0]
  def change
    create_table :discussion_replies do |t|
      t.references :discussion, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.text :content, null: false

      t.timestamps
    end

    add_index :discussion_replies, :created_at
  end
end
